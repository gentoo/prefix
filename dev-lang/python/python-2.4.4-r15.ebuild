# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/python/python-2.4.4-r15.ebuild,v 1.4 2009/02/26 05:28:46 vapier Exp $

# NOTE about python-portage interactions :
# - Do not add a pkg_setup() check for a certain version of portage
#   in dev-lang/python. It _WILL_ stop people installing from
#   Gentoo 1.4 images.

EAPI=1

inherit autotools eutils flag-o-matic python multilib versionator toolchain-funcs alternatives prefix

# we need this so that we don't depends on python.eclass
PYVER_MAJOR=$(get_major_version)
PYVER_MINOR=$(get_version_component_range 2)
PYVER="${PYVER_MAJOR}.${PYVER_MINOR}"

MY_P="Python-${PV}"
S="${WORKDIR}/${MY_P}"
DESCRIPTION="Python is an interpreted, interactive, object-oriented programming language."
HOMEPAGE="http://www.python.org/"
SRC_URI="http://www.python.org/ftp/python/${PV}/${MY_P}.tar.bz2
	mirror://gentoo/python-gentoo-patches-${PV}-r12.tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.4"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="ncurses gdbm ssl readline tk berkdb bootstrap ipv6 build ucs2 doc +cxx +threads examples elibc_uclibc wininst +xml"

# Can't be compiled against db-4.5 Bug #179377
DEPEND=">=sys-libs/zlib-1.1.3
	!dev-python/cjkcodecs
	!build? (
		tk? ( >=dev-lang/tk-8.0 )
		ncurses? ( >=sys-libs/ncurses-5.2 readline? ( >=sys-libs/readline-4.1 ) )
		berkdb? ( || ( sys-libs/db:4.4  sys-libs/db:4.3 ) )
		gdbm? ( sys-libs/gdbm )
		ssl? ( dev-libs/openssl )
		doc? ( dev-python/python-docs:2.4 )
		xml? ( dev-libs/expat )
	)"

# NOTE: changed RDEPEND to PDEPEND to resolve bug 88777. - kloeri
# NOTE: added blocker to enforce correct merge order for bug 88777. - zmedico

RDEPEND="${DEPEND} build? ( !dev-python/pycrypto )"
PDEPEND="${DEPEND} app-admin/python-updater"

PROVIDE="virtual/python"

src_unpack() {
	unpack ${A}

	# prefix adjustments of python-updater
	cp "${FILESDIR}"/python-updater-r1 "${T}"/python-updater-r1
	cd "${T}"
	epatch "${FILESDIR}"/python-updater-r1-prefix.patch
	eprefixify python-updater-r1

	cd "${WORKDIR}/${PV}"
	epatch "${FILESDIR}"/${PN}-2.4.4-readline.delta.patch

	cd "${S}"

	if tc-is-cross-compiler ; then
		epatch "${FILESDIR}"/python-2.4.4-test-cross.patch
	else
		rm "${WORKDIR}/${PV}"/*_all_crosscompile.patch
	fi

	EPATCH_SUFFIX="patch" epatch "${WORKDIR}/${PV}"
	sed -i -e "s:@@GENTOO_LIBDIR@@:$(get_libdir):g" \
		Lib/distutils/command/install.py \
		Lib/distutils/sysconfig.py \
		Lib/site.py \
		Makefile.pre.in \
		Modules/Setup.dist \
		Modules/getpath.c \
		setup.py || die

	# fix os.utime() on hppa. utimes it not supported but unfortunately
	# reported as working - gmsoft (22 May 04)
	# PLEASE LEAVE THIS FIX FOR NEXT VERSIONS AS IT'S A CRITICAL FIX !!!
	[ "${ARCH}" = "hppa" ] && sed -e 's/utimes //' -i "${S}"/configure

	# python has some gcc-apple specific CFLAGS built in... rip them out
	epatch "${FILESDIR}"/${P}-darwin-fsf-gcc.patch
	# python defaults to using .so files... so stupid
	epatch "${FILESDIR}"/${P}-darwin-bundle.patch
	# python doesn't build a libpython2.4.dylib by itself...
	epatch "${FILESDIR}"/${P}-darwin-libpython2.4.patch
	# and to build this lib, we need -fno-common, which python doesn't use, and
	# to have _NSGetEnviron being used, which by default it isn't...
	[[ ${CHOST} == *-darwin* ]] && \
		append-flags -fno-common -DWITH_NEXT_FRAMEWORK

	# do not use 'which' to find binaries, but go through the PATH.
	epatch "${FILESDIR}"/${P}-ld_so_aix-which.patch

	# enforce LINKCC to use gcc to prevent python from being linked to libstdc++.so
	epatch "${FILESDIR}"/${P}-linkcc.patch

	if ! use wininst; then
		# remove microsoft windows executables
		rm Lib/distutils/command/wininst-*.exe
	fi

	eautoreconf
}

src_configure() {
	# disable extraneous modules with extra dependencies
	if use build; then
		export PYTHON_DISABLE_MODULES="readline pyexpat dbm gdbm bsddb _curses _curses_panel _tkinter"
		export PYTHON_DISABLE_SSL=1
	else
		# dbm module can link to berkdb or gdbm -- defaults to gdbm when
		# both are enabled, see #204343
		use berkdb || use gdbm \
			|| PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} dbm"
		use gdbm \
			|| PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} gdbm"
		use berkdb \
			|| PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} bsddb"
		use readline \
			|| PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} readline"
		use tk \
			|| PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} _tkinter"
		use ncurses \
			|| PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} _curses _curses_panel"
		use ssl \
			|| export PYTHON_DISABLE_SSL=1
		use xml \
			|| PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} pyexpat"

		export PYTHON_DISABLE_MODULES

		if use !xml; then
			ewarn "You have configured Python without XML support."
			ewarn "This is NOT a recommended configuration as you"
			ewarn "may face problems parsing any XML documents."
		fi

		einfo "Disabled modules: $PYTHON_DISABLE_MODULES"
	fi
}

src_compile() {
	filter-flags -malign-double

	# Seems to no longer be necessary
	#[ "${ARCH}" = "amd64" ] && append-flags -fPIC
	[ "${ARCH}" = "alpha" ] && append-flags -fPIC

	# http://bugs.gentoo.org/show_bug.cgi?id=50309
	if is-flag -O3; then
		is-flag -fstack-protector-all && replace-flags -O3 -O2
		use hardened && replace-flags -O3 -O2
	fi

	export OPT="${CFLAGS}"

	local myconf
	#if we are creating a new build image, we remove the dependency on g++
	if use build && ! use bootstrap || ! use cxx ; then
		myconf="--with-cxx=no"
	fi

	# super-secret switch. don't use this unless you know what you're
	# doing. enabling UCS2 support will break your existing python
	# modules
	use ucs2 \
		&& myconf="${myconf} --enable-unicode=ucs2" \
		|| myconf="${myconf} --enable-unicode=ucs4"

	use threads \
		&& myconf="${myconf} --with-threads" \
		|| myconf="${myconf} --without-threads"

	src_configure

	if tc-is-cross-compiler ; then
		OPT="-O1" CFLAGS="" LDFLAGS="" CC="" \
		./configure --with-cxx=no --{build,host}=${CBUILD} || die "cross-configure failed"
		emake python Parser/pgen || die "cross-make failed"
		mv python hostpython
		mv Parser/pgen Parser/hostpgen
		make distclean
		sed -i \
			-e '/^HOSTPYTHON/s:=.*:=./hostpython:' \
			-e '/^HOSTPGEN/s:=.*:=./Parser/hostpgen:' \
			Makefile.pre.in || die
	fi

	# export CXX so it ends up in /usr/lib/python2.x/config/Makefile
	tc-export CXX
	econf \
		--with-fpectl \
		--enable-shared \
		`use_enable ipv6` \
		--infodir='${prefix}'/share/info \
		--mandir='${prefix}'/share/man \
		--with-libc='' \
		--disable-framework \
		--disable-toolbox-glue \
		--with-gcc \
		${myconf} || die
	emake || die "Parallel make failed"
	if [[ ${CHOST} == *-darwin* ]] ; then
		# create libpython on Darwin
		emake libpython2.4.dylib || die
	fi
}

src_install() {
	dodir /usr
	src_configure
	make DESTDIR="${D}" altinstall maninstall || die

	# install our own custom python-config
	exeinto /usr/bin
	newexe "${FILESDIR}"/python-config-${PYVER}-r1 python-config-${PYVER}

	# Use correct libdir in python-config
	dosed "s:/usr/lib/:${EPREFIX}/usr/$(get_libdir)/:" /usr/bin/python-config-${PYVER}
	# Use correct shebang
	dosed "1s|^#!/usr/bin/python$|#!${EPREFIX}/usr/bin/python|" /usr/bin/python-config-${PYVER}

	if use build ; then
		rm -rf "${ED}"/usr/$(get_libdir)/python${PYVER}/{test,encodings,email,lib-tk,bsddb/test}
	else
		use elibc_uclibc && rm -rf "${ED}"/usr/$(get_libdir)/python${PYVER}/{test,bsddb/test}
		use berkdb || rm -rf "${ED}"/usr/$(get_libdir)/python${PYVER}/bsddb
		use tk || rm -rf "${ED}"/usr/$(get_libdir)/python${PYVER}/lib-tk
	fi

	# Fix slotted collisions
	mv "${ED}"/usr/bin/pydoc "${ED}"/usr/bin/pydoc${PYVER}
	mv "${ED}"/usr/bin/idle "${ED}"/usr/bin/idle${PYVER}
	mv "${ED}"/usr/share/man/man1/python.1 \
		"${ED}"/usr/share/man/man1/python${PYVER}.1
	rm -f "${ED}"/usr/bin/smtpd.py

	prep_ml_includes usr/include/python${PYVER}

	# The stuff below this line extends from 2.1, and should be deprecated
	# in 2.3, or possibly can wait till 2.4

	# seems like the build do not install Makefile.pre.in anymore
	# it probably shouldn't - use DistUtils, people!
	insinto /usr/$(get_libdir)/python${PYVER}/config
	doins "${S}"/Makefile.pre.in

	# While we're working on the config stuff... Let's fix the OPT var
	# so that it doesn't have any opts listed in it. Prevents the problem
	# with compiling things with conflicting opts later.
	dosed -e 's:^OPT=.*:OPT=-DNDEBUG:' \
			/usr/$(get_libdir)/python${PYVER}/config/Makefile

	if use examples ; then
		insinto /usr/share/doc/${PF}/examples
		doins -r "${S}"/Tools || die "doins failed"
	fi

	newinitd "${FILESDIR}/pydoc.init" pydoc-${SLOT}
	newconfd "${FILESDIR}/pydoc.conf" pydoc-${SLOT}
}

pkg_postrm() {
	local mansuffix=$(ecompress --suffix)
	python_makesym
	alternatives_auto_makesym "/usr/bin/idle" "idle[0-9].[0-9]"
	alternatives_auto_makesym "/usr/bin/pydoc" "pydoc[0-9].[0-9]"
	alternatives_auto_makesym "/usr/bin/python-config" \
								"python-config-[0-9].[0-9]"
	alternatives_auto_makesym "/usr/share/man/man1/python.1${mansuffix}" \
								"python[0-9].[0-9].1${mansuffix}"

	python_mod_cleanup /usr/lib/python${PYVER}
	[[ "$(get_libdir)" == "lib" ]] || \
		python_mod_cleanup /usr/$(get_libdir)/python${PYVER}
}

pkg_postinst() {
	local myroot
	myroot=$(echo $ROOT | sed 's:/$::')
	local mansuffix=$(ecompress --suffix)

	python_makesym
	alternatives_auto_makesym "/usr/bin/idle" "idle[0-9].[0-9]"
	alternatives_auto_makesym "/usr/bin/pydoc" "pydoc[0-9].[0-9]"
	alternatives_auto_makesym "/usr/bin/python-config" \
								"python-config-[0-9].[0-9]"
	alternatives_auto_makesym "/usr/share/man/man1/python.1${mansuffix}" \
								"python[0-9].[0-9].1${mansuffix}"

	python_mod_optimize
	python_mod_optimize -x "(site-packages|test)" \
						/usr/lib/python${PYVER}
	[[ "$(get_libdir)" == "lib" ]] || \
		python_mod_optimize -x "(site-packages|test)" \
							/usr/$(get_libdir)/python${PYVER}

	# workaround possible python-upgrade-breaks-portage situation
	if [ ! -f ${myroot}/usr/lib/portage/pym/portage.py ]; then
		if [ -f ${myroot}/usr/lib/python2.3/site-packages/portage.py ]; then
			einfo "Working around possible python-portage upgrade breakage"
			mkdir -p ${myroot}/usr/lib/portage/pym
			cp ${myroot}/usr/lib/python2.4/site-packages/{portage,xpak,output,cvstree,getbinpkg,emergehelp,dispatch_conf}.py ${myroot}/usr/lib/portage/pym
			python_mod_optimize /usr/lib/portage/pym
		fi
	fi

	echo
	ewarn
	ewarn "If you have just upgraded from an older version of python you"
	ewarn "will need to run:"
	ewarn
	ewarn "${EPREFIX}/usr/sbin/python-updater"
	ewarn
	ewarn "This will automatically rebuild all the python dependent modules"
	ewarn "to run with python-${PYVER}."
	ewarn
	ewarn "Your original Python is still installed and can be accessed via"
	ewarn "${EPREFIX}/usr/bin/python2.x."
	ewarn
	ebeep 5
}

src_test() {
	# Tests won't work when cross compiling
	if tc-is-cross-compiler ; then
		elog "Disabling tests due to crosscompiling."
		return
	fi

	# Disabling byte compiling breaks test_import
	python_enable_pyc

	#skip all tests that fail during emerge but pass without emerge:
	#(See bug# 67970)
	local skip_tests="cookielib distutils global hotshot mimetools minidom mmap posix sax strptime subprocess syntax tcl time urllib urllib2"

	# test_pow fails on alpha.
	# http://bugs.python.org/issue756093
	[[ ${ARCH} == "alpha" ]] && skip_tests="${skip_tests} pow"

	for test in ${skip_tests} ; do
		mv "${S}"/Lib/test/test_${test}.py "${T}"
	done

	# rerun failed tests in verbose mode (regrtest -w)
	EXTRATESTOPTS="-w" make test || die "make test failed"

	for test in ${skip_tests} ; do
		mv "${T}"/test_${test}.py "${S}"/Lib/test/test_${test}.py
	done

	elog "Portage skipped the following tests which aren't able to run from emerge:"
	for test in ${skip_tests} ; do
		elog "test_${test}.py"
	done

	elog "If you'd like to run them, you may:"
	elog "cd /usr/lib/python${PYVER}/test"
	elog "and run the tests separately."
}
