# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/python/python-2.4.4-r4.ebuild,v 1.14 2007/05/16 21:13:06 dertobi123 Exp $

EAPI="prefix"

# NOTE about python-portage interactions :
# - Do not add a pkg_setup() check for a certain version of portage
#   in dev-lang/python. It _WILL_ stop people installing from
#   Gentoo 1.4 images.

inherit autotools eutils flag-o-matic python multilib versionator toolchain-funcs alternatives

# we need this so that we don't depends on python.eclass
PYVER_MAJOR=$(get_major_version)
PYVER_MINOR=$(get_version_component_range 2)
PYVER="${PYVER_MAJOR}.${PYVER_MINOR}"

MY_P="Python-${PV}"
S="${WORKDIR}/${MY_P}"
DESCRIPTION="Python is an interpreted, interactive, object-oriented programming language."
HOMEPAGE="http://www.python.org/"
SRC_URI="http://www.python.org/ftp/python/${PV}/${MY_P}.tar.bz2
	http://dev.gentoo.org/~kloeri/python-gentoo-patches-${PV}-r3.tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.4"
KEYWORDS="~amd64 ~ia64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="ncurses gdbm ssl readline tk berkdb bootstrap ipv6 build ucs2 doc nocxx nothreads examples"

DEPEND=">=sys-libs/zlib-1.1.3
	!dev-python/cjkcodecs
	!build? (
		tk? ( >=dev-lang/tk-8.0 )
		ncurses? ( >=sys-libs/ncurses-5.2 readline? ( >=sys-libs/readline-4.1 ) )
		berkdb? ( >=sys-libs/db-3.1 )
		gdbm? ( sys-libs/gdbm )
		ssl? ( dev-libs/openssl )
		doc? ( =dev-python/python-docs-${PV}* )
		dev-libs/expat
	)"

# NOTE: The dev-python/python-fchksum RDEPEND is needed so that this python
#       provides the functionality expected from previous pythons.

# NOTE: python-fchksum is only a RDEPEND and not a DEPEND since we don't need
#       it to compile python. We just need to ensure that when we install
#       python, we definitely have fchksum support. - liquidx

# NOTE: changed RDEPEND to PDEPEND to resolve bug 88777. - kloeri

PDEPEND="${DEPEND} 	dev-python/python-fchksum app-admin/python-updater"

PROVIDE="virtual/python"

# confcache breaks a dlopen check, causing python to not support
# loading .so files - marienz
RESTRICT="confcache"

src_unpack() {
	unpack ${A}

	# prefix adjustments of python-updater
	cp "${FILESDIR}"/python-updater-r1 "${T}"/python-updater-r1
	cd "${T}"
	epatch "${FILESDIR}"/python-updater-r1-prefix.patch
	eprefixify python-updater-r1

	cd ${S}

	if tc-is-cross-compiler ; then
		[[ $(python -V) != ${PV} ]] && \
			die "Crosscompiling requires the same host and build versions."
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
	[ "${ARCH}" = "hppa" ] && sed -e 's/utimes //' -i ${S}/configure

	# python has some gcc-apple specific CFLAGS built in... rip them out
	epatch "${FILESDIR}"/${P}-darwin-fsf-gcc.patch
	# python defaults to using .so files... so stupid
	epatch "${FILESDIR}"/${P}-darwin-dylib.patch

	# do not use 'which' to find binaries, but go through the PATH.
	epatch "${FILESDIR}"/${P}-ld_so_aix-which.patch

	# enforce LINKCC to use gcc to prevent python from being linked to libstdc++.so
	epatch "${FILESDIR}"/${P}-linkcc.patch

	eautoreconf
}

src_configure() {
	# disable extraneous modules with extra dependencies
	if use build; then
		export PYTHON_DISABLE_MODULES="readline pyexpat dbm gdbm bsddb _curses _curses_panel _tkinter"
		export PYTHON_DISABLE_SSL=1
	else
		use gdbm \
			|| PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} gdbm"
		use berkdb \
			|| PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} dbm bsddb"
		use readline \
			|| PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} readline"
		use tk \
			|| PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} _tkinter"
		use ncurses \
			|| PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} _curses _curses_panel"
		use ssl \
			|| export PYTHON_DISABLE_SSL=1
		export PYTHON_DISABLE_MODULES
		echo $PYTHON_DISABLE_MODULES
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
	if use build && ! use bootstrap || use nocxx ; then
		myconf="--with-cxx=no"
	fi

	# super-secret switch. don't use this unless you know what you're
	# doing. enabling UCS2 support will break your existing python
	# modules
	use ucs2 \
		&& myconf="${myconf} --enable-unicode=ucs2" \
		|| myconf="${myconf} --enable-unicode=ucs4"

	use nothreads \
		&& myconf="${myconf} --without-threads" \
		|| myconf="${myconf} --with-threads"

	src_configure

	if tc-is-cross-compiler ; then
		OPT="-O1" CFLAGS="" LDFLAGS="" CC="" \
			./configure --with-cxx=no || die "cross-configure failed"
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
}

src_install() {
	dodir /usr
	src_configure
	make DESTDIR="${D}" altinstall maninstall || die

	# install our own custom python-config
	exeinto /usr/bin
	doexe ${FILESDIR}/python-config-${PYVER}

	# Use correct libdir in python-config
	dosed "s:/usr/lib/:${EPREFIX}/usr/$(get_libdir)/:" /usr/bin/python-config-${PYVER}
	# Use correct shebang
	dosed "1s|^#!/usr/bin/python$|#!${EPREFIX}/usr/bin/python|" /usr/bin/python-config-${PYVER}

	if use build ; then
		rm -rf ${ED}/usr/$(get_libdir)/python${PYVER}/{test,encodings,email,lib-tk,bsddb/test}
	else
		use elibc_uclibc && rm -rf ${ED}/usr/$(get_libdir)/python${PYVER}/{test,bsddb/test}
		use berkdb || rm -rf ${ED}/usr/$(get_libdir)/python${PYVER}/bsddb
		use tk || rm -rf ${ED}/usr/$(get_libdir)/python${PYVER}/lib-tk
	fi

	# Fix slotted collisions
	mv ${ED}/usr/bin/pydoc ${ED}/usr/bin/pydoc${PYVER}
	mv ${ED}/usr/bin/idle ${ED}/usr/bin/idle${PYVER}
	mv ${ED}/usr/share/man/man1/python.1 \
		${ED}/usr/share/man/man1/python${PYVER}.1
	rm -f ${ED}/usr/bin/smtpd.py

	prep_ml_includes usr/include/python${PYVER}


	# The stuff below this line extends from 2.1, and should be deprecated
	# in 2.3, or possibly can wait till 2.4

	# seems like the build do not install Makefile.pre.in anymore
	# it probably shouldn't - use DistUtils, people!
	insinto /usr/$(get_libdir)/python${PYVER}/config
	doins ${S}/Makefile.pre.in

	# While we're working on the config stuff... Let's fix the OPT var
	# so that it doesn't have any opts listed in it. Prevents the problem
	# with compiling things with conflicting opts later.
	dosed -e 's:^OPT=.*:OPT=-DNDEBUG:' \
			/usr/$(get_libdir)/python${PYVER}/config/Makefile

	if use examples ; then
		mkdir -p ${ED}/usr/share/doc/${P}/examples
		cp -r ${S}/Tools ${ED}/usr/share/doc/${P}/examples
	fi
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
	python_mod_optimize -x site-packages \
						-x test ${myroot}/usr/lib/python${PYVER}
	[[ "$(get_libdir)" == "lib" ]] || \
		python_mod_optimize -x site-packages \
							-x test ${myroot}/usr/$(get_libdir)/python${PYVER}


	# workaround possible python-upgrade-breaks-portage situation
	if [ ! -f ${myroot}/usr/lib/portage/pym/portage.py ]; then
		if [ -f ${myroot}/usr/lib/python2.3/site-packages/portage.py ]; then
			einfo "Working around possible python-portage upgrade breakage"
			mkdir -p ${myroot}/usr/lib/portage/pym
			cp ${myroot}/usr/lib/python2.4/site-packages/{portage,xpak,output,cvstree,getbinpkg,emergehelp,dispatch_conf}.py ${myroot}/usr/lib/portage/pym
			python_mod_optimize ${myroot}/usr/lib/portage/pym
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

	# PYTHON_DONTCOMPILE=1 breaks test_import
	unset PYTHON_DONTCOMPILE

	#skip all tests that fail during emerge but pass without emerge:
	#(See bug# 67970)
	local skip_tests="cookielib distutils global hotshot mimetools minidom mmap posix sax strptime subprocess syntax tcl time urllib urllib2"

	for test in ${skip_tests} ; do
		mv ${S}/Lib/test/test_${test}.py ${T}
	done

	# rerun failed tests in verbose mode (regrtest -w)
	EXTRATESTOPTS="-w" make test || die "make test failed"

	for test in ${skip_tests} ; do
		mv ${T}/test_${test}.py ${S}/Lib/test/test_${test}.py
	done

	elog "Portage skipped the following tests which aren't able to run from emerge:"
	for test in ${skip_tests} ; do
		elog "test_${test}.py"
	done

	elog "If you'd like to run them, you may:"
	elog "cd /usr/lib/python${PYVER}/test"
	elog "and run the tests separately."
}
