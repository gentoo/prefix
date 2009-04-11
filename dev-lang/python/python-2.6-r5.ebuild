# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/python/python-2.6-r5.ebuild,v 1.7 2009/03/26 05:10:31 zmedico Exp $

# NOTE about python-portage interactions :
# - Do not add a pkg_setup() check for a certain version of portage
#   in dev-lang/python. It _WILL_ stop people installing from
#   Gentoo 1.4 images.

EAPI=2

inherit eutils autotools flag-o-matic python multilib versionator toolchain-funcs libtool

# we need this so that we don't depends on python.eclass
PYVER_MAJOR=$(get_major_version)
PYVER_MINOR=$(get_version_component_range 2)
PYVER="${PYVER_MAJOR}.${PYVER_MINOR}"

MY_P="Python-${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Python is an interpreted, interactive, object-oriented programming language."
HOMEPAGE="http://www.python.org/"
SRC_URI="http://www.python.org/ftp/python/2.6/${MY_P}.tar.bz2
	mirror://gentoo/python-gentoo-patches-${PVR}.tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.6"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="+xml ncurses gdbm ssl readline tk berkdb ipv6 build ucs2 sqlite doc +threads examples elibc_uclibc wininst"

# NOTE: dev-python/{elementtree,celementtree,pysqlite,ctypes,cjkcodecs}
#       do not conflict with the ones in python proper. - liquidx

DEPEND=">=app-admin/eselect-python-20080925
	>=sys-libs/zlib-1.1.3
	!build? (
		sqlite? ( >=dev-db/sqlite-3 )
		tk? ( >=dev-lang/tk-8.0 )
		ncurses? ( >=sys-libs/ncurses-5.2
					readline? ( >=sys-libs/readline-4.1 ) )
		berkdb? ( >=sys-libs/db-3.1 )
		gdbm? ( sys-libs/gdbm )
		ssl? ( dev-libs/openssl )
		doc? ( dev-python/python-docs:2.6 )
		xml? ( dev-libs/expat )
	)"

# NOTE: changed RDEPEND to PDEPEND to resolve bug 88777. - kloeri
# NOTE: added blocker to enforce correct merge order for bug 88777. - zmedico

PDEPEND="${DEPEND} app-admin/python-updater"
PROVIDE="virtual/python"

src_prepare() {
	default

	if tc-is-cross-compiler ; then
		epatch "${FILESDIR}"/python-2.6-test-cross.patch
	else
		rm "${WORKDIR}/${PV}"/*_all_crosscompile.patch
	fi

	# stupidos hardcoding GNU specifics
	[[ ${CHOST} == *-linux-gnu || ${CHOST} == *-solaris* || ${CHOST} == *bsd* ]] || \
		EPATCH_EXCLUDE=21_all_ctypes-execstack.patch
	EPATCH_SUFFIX="patch" epatch "${WORKDIR}/${PV}"

	sed -i -e "s:@@GENTOO_LIBDIR@@:$(get_libdir):g" \
		Lib/distutils/command/install.py \
		Lib/distutils/sysconfig.py \
		Lib/site.py \
		Makefile.pre.in \
		Modules/Setup.dist \
		Modules/getpath.c \
		setup.py || die "sed failed to replace @@GENTOO_LIBDIR@@"

	# fix os.utime() on hppa. utimes it not supported but unfortunately reported as working - gmsoft (22 May 04)
	# PLEASE LEAVE THIS FIX FOR NEXT VERSIONS AS IT'S A CRITICAL FIX !!!
	[ "${ARCH}" = "hppa" ] && sed -e 's/utimes //' -i "${S}"/configure

	if ! use wininst; then
		# remove microsoft windows executables
		rm Lib/distutils/command/wininst-*.exe
	fi

	# python has some gcc-apple specific CFLAGS built in... rip them out
#	epatch "${FILESDIR}"/${PN}-2.4.4-darwin-fsf-gcc.patch
	# python defaults to using .so files, however they are bundles
	epatch "${FILESDIR}"/${PN}-2.5.1-darwin-bundle.patch
	# python doesn't build a libpython2.5.dylib by itself...
	epatch "${FILESDIR}"/${PN}-2.6-darwin-libpython2.6.patch
	# and to build this lib, we need -fno-common, which python doesn't use, and
	# to have _NSGetEnviron being used, which by default it isn't...
	[[ ${CHOST} == *-darwin* ]] && \
		append-flags -fno-common -DWITH_NEXT_FRAMEWORK

	use prefix && epatch "${FILESDIR}"/${PN}-2.5.1-no-usrlocal.patch

	epatch "${FILESDIR}"/${PN}-2.5.1-darwin-gcc-version.patch

	# set RUNSHARED for 'regen' in Lib/plat-*
	epatch "${FILESDIR}"/${PN}-2.5.1-platdir-runshared.patch

	# on hpux, use gcc to link if used to compile
#	epatch "${FILESDIR}"/${PN}-2.5.1-hpux-ldshared.patch

	# do not use 'which' to find binaries, but go through the PATH.
	epatch "${FILESDIR}"/${PN}-2.4.4-ld_so_aix-which.patch
	# better use mutexes on aix5 instead of semaphores.
#	epatch "${FILESDIR}"/${PN}-2.4.4-aix-semaphores.patch
	# build shared library on aix
#	epatch "${FILESDIR}"/${PN}-2.5.1-aix-ldshared.patch
	# at least IRIX starts spitting out ugly errors, but we want to use prefix
	# grep anyway
	epatch "${FILESDIR}"/${PN}-2.5.1-no-hardcoded-grep.patch
	# AIX sometimes keeps ".nfsXXX" files around: ignore them in distutils
	epatch "${FILESDIR}"/${PN}-2.5.1-distutils-aixnfs.patch

	# patch to make python behave nice with interix. There is one part
	# maybe affecting other x86-platforms, thus conditional.
	[[ ${CHOST} == *-interix* ]] && {
		epatch "${FILESDIR}"/${PN}-2.5.1-interix.patch
		# this one could be applied unconditionally, but to keep it
		# clean, i do it together with the conditional one.
		epatch "${FILESDIR}"/${PN}-2.5.1-interix-sleep.patch
	}

	eautoreconf
}

src_configure() {
	# disable extraneous modules with extra dependencies
	if use build; then
		export PYTHON_DISABLE_MODULES="readline pyexpat dbm gdbm bsddb _curses _curses_panel _tkinter _sqlite3"
		export PYTHON_DISABLE_SSL=1
	else
		# dbm module can link to berkdb or gdbm
		# defaults to gdbm when both are enabled, #204343
		local disable
		use berkdb   || use gdbm || disable="${disable} dbm"
		use berkdb   || disable="${disable} bsddb"
		use xml      || disable="${disable} pyexpat"
		use gdbm     || disable="${disable} gdbm"
		use ncurses  || disable="${disable} _curses _curses_panel"
		use readline || disable="${disable} readline"
		use sqlite   || disable="${disable} sqlite3"
		use ssl      || export PYTHON_DISABLE_SSL=1
		use tk       || disable="${disable} _tkinter"
		export PYTHON_DISABLE_MODULES="${disable}"
	fi

	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no

	filter-flags -malign-double

	if use !xml; then
		ewarn "You have configured Python without XML support."
		ewarn "This is NOT a recommended configuration as you"
		ewarn "may face problems parsing any XML documents."
	fi

	einfo "Disabled modules: $PYTHON_DISABLE_MODULES"

	export OPT="${CFLAGS}"

	local myconf

	# super-secret switch. don't use this unless you know what you're
	# doing. enabling UCS2 support will break your existing python
	# modules
	use ucs2 \
		&& myconf="${myconf} --enable-unicode=ucs2" \
		|| myconf="${myconf} --enable-unicode=ucs4"

	filter-flags -malign-double

	# Seems to no longer be necessary
	#[ "${ARCH}" = "amd64" ] && append-flags -fPIC
	[ "${ARCH}" = "alpha" ] && append-flags -fPIC

	# http://bugs.gentoo.org/show_bug.cgi?id=50309
	if is-flag -O3; then
	   is-flag -fstack-protector-all && replace-flags -O3 -O2
	   use hardened && replace-flags -O3 -O2
	fi

	if tc-is-cross-compiler ; then
		OPT="-O1" CFLAGS="" LDFLAGS="" CC="" \
		./configure --{build,host}=${CBUILD} || die "cross-configure failed"
		emake python Parser/pgen || die "cross-make failed"
		mv python hostpython
		mv Parser/pgen Parser/hostpgen
		make distclean
		sed -i \
			-e '/^HOSTPYTHON/s:=.*:=./hostpython:' \
			-e '/^HOSTPGEN/s:=.*:=./Parser/hostpgen:' \
			Makefile.pre.in || die "sed failed"
	fi

	# export CXX so it ends up in /usr/lib/python2.x/config/Makefile
	tc-export CXX

	# set LDFLAGS so we link modules with -lpython2.5 correctly.
	# Needed on FreeBSD unless python2.5 is already installed.
	# Please query BSD team before removing this!
	append-ldflags "-L."

	# python defaults to use 'cc_r' on aix
	[[ ${CHOST} == *-aix* ]] && myconf="${myconf} --with-gcc=$(tc-getCC)"

	econf \
		--with-fpectl \
		--enable-shared \
		$(use_enable ipv6) \
		$(use_with threads) \
		--infodir='${prefix}'/share/info \
		--mandir='${prefix}'/share/man \
		--with-libc='' \
		${myconf}
}

src_compile() {
	emake || die "Parallel make failed"
	if [[ ${CHOST} == *-darwin* ]] ; then
		# create libpython on Darwin
		emake libpython2.6.dylib || die
	fi
}

src_install() {
	dodir /usr
	emake DESTDIR="${D}" altinstall maninstall || die

	mv "${ED}"/usr/bin/python${PYVER}-config "${ED}"/usr/bin/python-config-${PYVER}

	# Fix slotted collisions
	mv "${ED}"/usr/bin/2to3 "${ED}"/usr/bin/2to3-${PYVER}
	mv "${ED}"/usr/bin/pydoc "${ED}"/usr/bin/pydoc${PYVER}
	mv "${ED}"/usr/bin/idle "${ED}"/usr/bin/idle${PYVER}
	mv "${ED}"/usr/share/man/man1/python.1 \
		"${ED}"/usr/share/man/man1/python${PYVER}.1
	rm -f "${ED}"/usr/bin/smtpd.py

	# While we're working on the config stuff... Let's fix the OPT var
	# so that it doesn't have any opts listed in it. Prevents the problem
	# with compiling things with conflicting opts later.
	dosed -e 's:^OPT=.*:OPT=-DNDEBUG:' \
			/usr/$(get_libdir)/python${PYVER}/config/Makefile

	if use build ; then
		rm -rf "${ED}"/usr/$(get_libdir)/python${PYVER}/{test,encodings,email,lib-tk,bsddb/test}
	else
		use elibc_uclibc && rm -rf "${ED}"/usr/$(get_libdir)/python${PYVER}/{test,bsddb/test}
		use berkdb || rm -rf "${ED}"/usr/$(get_libdir)/python${PYVER}/bsddb
		use tk || rm -rf "${ED}"/usr/$(get_libdir)/python${PYVER}/lib-tk
	fi

	prep_ml_includes usr/include/python${PYVER}

	# The stuff below this line extends from 2.1, and should be deprecated
	# in 2.3, or possibly can wait till 2.4

	# seems like the build do not install Makefile.pre.in anymore
	# it probably shouldn't - use DistUtils, people!
	insinto /usr/$(get_libdir)/python${PYVER}/config
	doins "${S}"/Makefile.pre.in

	if use examples ; then
		insinto /usr/share/doc/${PF}/examples
		doins -r "${S}"/Tools || die "doins failed"
	fi

	newinitd "${FILESDIR}/pydoc.init" pydoc-${SLOT}
	newconfd "${FILESDIR}/pydoc.conf" pydoc-${SLOT}

	# Installs empty directory.
	rmdir "${ED}"/usr/$(get_libdir)/${PN}${PV}/lib-old
}

pkg_postrm() {
	eselect python update --ignore 3.0
	python_mod_cleanup /usr/$(get_libdir)/python${PYVER}
}

pkg_postinst() {
	eselect python update --ignore 3.0
	python_version

	python_mod_optimize -x "(site-packages|test)" \
						/usr/$(get_libdir)/python${PYVER}
}

src_test() {
	# Tests won't work when cross compiling
	if tc-is-cross-compiler ; then
		elog "Disabling tests due to crosscompiling."
		return
	fi

	# Byte compiling should be enabled here.
	# Otherwise test_import fails.
	python_enable_pyc

	#skip all tests that fail during emerge but pass without emerge:
	#(See bug# 67970)
	local skip_tests="distutils global httpservers mimetools minidom mmap posix pyexpat sax strptime subprocess syntax tcl time urllib urllib2 webbrowser xml_etree"

	# test_pow fails on alpha.
	# http://bugs.python.org/issue756093
	[[ ${ARCH} == "alpha" ]] && skip_tests="${skip_tests} pow"

	for test in ${skip_tests} ; do
		mv "${S}"/Lib/test/test_${test}.py "${T}"
	done

	# Redirect stdin from /dev/tty as a workaround for bug #248081.
	# rerun failed tests in verbose mode (regrtest -w)
	EXTRATESTOPTS="-w" make test < /dev/tty || die "make test failed"

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
