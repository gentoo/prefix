# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/python/python-2.6.2-r1.ebuild,v 1.13 2009/09/01 02:46:07 arfrever Exp $

# NOTE about python-portage interactions :
# - Do not add a pkg_setup() check for a certain version of portage
#   in dev-lang/python. It _WILL_ stop people installing from
#   Gentoo 1.4 images.

EAPI="2"

inherit autotools eutils flag-o-matic libtool multilib pax-utils python toolchain-funcs versionator

# We need this so that we don't depends on python.eclass
PYVER_MAJOR=$(get_major_version)
PYVER_MINOR=$(get_version_component_range 2)
PYVER="${PYVER_MAJOR}.${PYVER_MINOR}"

MY_P="Python-${PV}"
S="${WORKDIR}/${MY_P}"

PATCHSET_REVISION="4"

DESCRIPTION="Python is an interpreted, interactive, object-oriented programming language."
HOMEPAGE="http://www.python.org/"
SRC_URI="http://www.python.org/ftp/python/${PV}/${MY_P}.tar.bz2
	mirror://gentoo/python-gentoo-patches-${PV}$([[ "${PATCHSET_REVISION}" != "0" ]] && echo "-r${PATCHSET_REVISION}").tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.6"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="aqua berkdb build doc elibc_uclibc examples gdbm ipv6 ncurses readline sqlite ssl +threads tk ucs2 wininst +xml"

# NOTE: dev-python/{elementtree,celementtree,pysqlite,ctypes}
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
			doc? ( dev-python/python-docs:${SLOT} )
			xml? ( >=dev-libs/expat-2 )
	)"
RDEPEND="${DEPEND}"
PDEPEND="${DEPEND} app-admin/python-updater"

PROVIDE="virtual/python"

src_prepare() {
	if tc-is-cross-compiler; then
		epatch "${FILESDIR}/python-2.5-cross-printf.patch"
		epatch "${FILESDIR}/python-2.6-chflags-cross.patch"
		epatch "${FILESDIR}/python-2.6-test-cross.patch"
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

	# Fix os.utime() on hppa. utimes it not supported but unfortunately reported as working - gmsoft (22 May 04)
	# PLEASE LEAVE THIS FIX FOR NEXT VERSIONS AS IT'S A CRITICAL FIX !!!
	[[ "${ARCH}" == "hppa" ]] && sed -e "s/utimes //" -i "${S}/configure"

	if ! use wininst; then
		# Remove Microsoft Windows executables.
		rm Lib/distutils/command/wininst-*.exe
	fi

	use prefix && epatch "${FILESDIR}"/${PN}-2.5.1-no-usrlocal.patch

	# build static for mint
	[[ ${CHOST} == *-mint* ]] && epatch "${FILESDIR}"/${P}-mint.patch

	# python defaults to using .so files, however they are bundles
	epatch "${FILESDIR}"/${PN}-2.5.1-darwin-bundle.patch
	# need this to have _NSGetEnviron being used, which by default isn't...
	[[ ${CHOST} == *-darwin* ]] && \
		append-flags -DWITH_NEXT_FRAMEWORK
	epatch "${FILESDIR}"/${PN}-2.5.1-darwin-gcc-version.patch
	# for Mac weenies
	epatch "${FILESDIR}"/${P}-mac.patch
	epatch "${FILESDIR}"/${P}-mac-just-prefix.patch
	sed -i -e "s:@@APPLICATIONS_DIR@@:${EPREFIX}/Applications:g" \
		Mac/Makefile.in \
		Mac/IDLE/Makefile.in \
		Mac/Tools/Doc/setup.py \
		Mac/PythonLauncher/Makefile.in || die
	sed -i -e '/-DPREFIX=/s:$(prefix):${EPREFIX}:' \
		-e '/-DEXEC_PREFIX=/s:$(exec_prefix):${EPREFIX}:' \
		Makefile.pre.in || die

	# on hpux, use gcc to link if used to compile
#	epatch "${FILESDIR}"/${PN}-2.5.1-hpux-ldshared.patch

	# do not use 'which' to find binaries, but go through the PATH.
	epatch "${FILESDIR}"/${PN}-2.4.4-ld_so_aix-which.patch
	# at least IRIX starts spitting out ugly errors, but we want to use Prefix
	# grep anyway
	epatch "${FILESDIR}"/${PN}-2.5.1-no-hardcoded-grep.patch
	# make it compile on IRIX as well
	epatch "${FILESDIR}"/${P}-irix.patch
	# and generate a libpython2.6.so
	epatch "${FILESDIR}"/${PN}-2.6-irix-libpython2.6.patch
	# AIX sometimes keeps ".nfsXXX" files around: ignore them in distutils
	epatch "${FILESDIR}"/${PN}-2.5.1-distutils-aixnfs.patch

	# http://bugs.python.org/issue6308
	epatch "${FILESDIR}"/${P}-termios-noqnx.patch
	# http://bugs.python.org/issue6163
	epatch "${FILESDIR}"/${P}-hpuxgcc.patch

	# build shared library on aix #278845
	epatch "${FILESDIR}"/${P}-aix-shared.patch

	# patch to make python behave nice with interix. There is one part
	# maybe affecting other x86-platforms, thus conditional.
	if [[ ${CHOST} == *-interix* ]] ; then
		epatch "${FILESDIR}"/${PN}-2.6.1-interix.patch
		# this one could be applied unconditionally, but to keep it
		# clean, I do it together with the conditional one.
		epatch "${FILESDIR}"/${PN}-2.5.1-interix-sleep.patch
		# some more modules fixed (_multiprocessing, dl)
		epatch "${FILESDIR}"/${P}-interix-modules.patch
	fi

	# Don't silence output of setup.py.
	sed -e '/setup\.py -q build/d' -i Makefile.pre.in

	# Fix OtherFileTests.testStdin() not to assume
	# that stdin is a tty for bug #248081.
	sed -e "s:'osf1V5':'osf1V5' and sys.stdin.isatty():" -i Lib/test/test_file.py || die "sed failed"

	eautoreconf
}

src_configure() {
	# Disable extraneous modules with extra dependencies.
	if use build; then
		export PYTHON_DISABLE_MODULES="dbm bsddb gdbm _curses _curses_panel readline _sqlite3 _tkinter _elementtree pyexpat"
		export PYTHON_DISABLE_SSL="1"
	else
		# dbm module can be linked against berkdb or gdbm.
		# Defaults to gdbm when both are enabled, #204343.
		local disable
		use berkdb   || use gdbm || disable+=" dbm"
		use berkdb   || disable+=" bsddb"
		use gdbm     || disable+=" gdbm"
		use ncurses  || disable+=" _curses _curses_panel"
		use readline || disable+=" readline"
		use sqlite   || disable+=" _sqlite3"
		use ssl      || export PYTHON_DISABLE_SSL="1"
		use tk       || disable+=" _tkinter"
		use xml      || disable+=" _elementtree pyexpat" # _elementtree uses pyexpat.
		export PYTHON_DISABLE_MODULES="${disable}"

		if ! use xml; then
			ewarn "You have configured Python without XML support."
			ewarn "This is NOT a recommended configuration as you"
			ewarn "may face problems parsing any XML documents."
		fi
	fi

	if [[ -n "${PYTHON_DISABLE_MODULES}" ]]; then
		einfo "Disabled modules: ${PYTHON_DISABLE_MODULES}"
	fi

	export OPT="${CFLAGS}"

	local myconf

	# Super-secret switch. Don't use this unless you know what you're
	# doing. Enabling UCS2 support will break your existing python
	# modules
	use ucs2 \
		&& myconf="${myconf} --enable-unicode=ucs2" \
		|| myconf="${myconf} --enable-unicode=ucs4"

	filter-flags -malign-double

	[[ "${ARCH}" == "alpha" ]] && append-flags -fPIC

	# https://bugs.gentoo.org/show_bug.cgi?id=50309
	if is-flag -O3; then
		is-flag -fstack-protector-all && replace-flags -O3 -O2
		use hardened && replace-flags -O3 -O2
	fi

	if tc-is-cross-compiler; then
		OPT="-O1" CFLAGS="" LDFLAGS="" CC="" \
		./configure --{build,host}=${CBUILD} || die "cross-configure failed"
		emake python Parser/pgen || die "cross-make failed"
		mv python hostpython
		mv Parser/pgen Parser/hostpgen
		make distclean
		sed -i \
			-e "/^HOSTPYTHON/s:=.*:=./hostpython:" \
			-e "/^HOSTPGEN/s:=.*:=./Parser/hostpgen:" \
			Makefile.pre.in || die "sed failed"
	fi

	# Export CXX so it ends up in /usr/lib/python2.X/config/Makefile.
	tc-export CXX

	# Set LDFLAGS so we link modules with -lpython2.6 correctly.
	# Needed on FreeBSD unless Python 2.6 is already installed.
	# Please query BSD team before removing this!
	append-ldflags "-L."

	# python defaults to use 'cc_r' on aix
	[[ ${CHOST} == *-aix* ]] && myconf="${myconf} --with-gcc=$(tc-getCC)"

	# Don't include libmpc on IRIX - it is only available for 64bit MIPS4
	[[ ${CHOST} == *-irix* ]] && export ac_cv_lib_mpc_usconfig=no

	# Interix poll is broken
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no

	[[ ${CHOST} == *-mint* ]] && export ac_cv_func_poll=no

	# we need this to get pythonw, the GUI version of python
	# --enable-framework and --enable-shared are mutually exclusive:
	# http://bugs.python.org/issue5809
	use aqua \
		&& myconf="${myconf} --enable-framework=${EPREFIX}/usr/lib" \
		|| myconf="${myconf} --enable-shared"

	econf \
		--with-fpectl \
		$(use_enable ipv6) \
		$(use_with threads) \
		--infodir='${prefix}'/share/info \
		--mandir='${prefix}'/share/man \
		--with-libc='' \
		${myconf}
}

src_test() {
	# Tests won't work when cross compiling.
	if tc-is-cross-compiler; then
		elog "Disabling tests due to crosscompiling."
		return
	fi

	# Byte compiling should be enabled here.
	# Otherwise test_import fails.
	python_enable_pyc

	# Skip all tests that fail during emerge but pass without emerge:
	# (See bug #67970)
	local skip_tests="distutils global httpservers mimetools minidom mmap posix pyexpat sax strptime subprocess syntax tcl time urllib urllib2 xml_etree"

	# test_ctypes fails with PAX kernel (bug #234498).
	host-is-pax && skip_tests+=" ctypes"

	for test in ${skip_tests}; do
		mv "${S}"/Lib/test/test_${test}.py "${T}"
	done

	# Rerun failed tests in verbose mode (regrtest -w).
	EXTRATESTOPTS="-w" make test || die "make test failed"

	for test in ${skip_tests}; do
		mv "${T}"/test_${test}.py "${S}"/Lib/test/test_${test}.py
	done

	elog "The following tests have been skipped:"
	for test in ${skip_tests}; do
		elog "test_${test}.py"
	done

	elog "If you'd like to run them, you may:"
	elog "cd /usr/$(get_libdir)/python${PYVER}/test"
	elog "and run the tests separately."
}

src_install() {
	[[ ${CHOST} == *-mint* ]] && keepdir /usr/lib/python${PYVER}/lib-dynload/
	# do not make multiple targets in parallel when there are broken
	# sharedmods (during bootstrap), would build them twice in parallel.
	if use aqua ; then
		emake -j1 CC=$(tc-getCC) DESTDIR="${D}" frameworkinstall || die "emake frameworkinstall failed"
		# don't install the "Current" symlinks, will always conflict
		local fwdir="${EPREFIX}"/usr/lib/Python.framework
		for sym in Headers Resources Python Versions/Current ; do
			rm "${D}${fwdir}"/${sym} || die "missing symlink ${fwdir}/${sym}?"
		done
		# basically we don't like the framework stuff at all, so just add some
		# symlinks to make our life easier
		mkdir -p "${ED}"/usr/share/man/man1
		ln -s "${fwdir}"/Versions/${PYVER}/share/man/man1/python.1 \
			"${ED}"/usr/share/man/man1/
		mkdir -p "${ED}"/usr/bin
		ln -s "${fwdir}"/Versions/${PYVER}/bin/2to3 \
			"${ED}"/usr/bin/
		mkdir -p "${ED}"/usr/include
		ln -s "${fwdir}"/Versions/${PYVER}/include/python${PYVER} \
			"${ED}"/usr/include/
		# can't symlink the entire dir, because a real dir already exists on
		# upgrade (site-packages), however since we h4x0rzed python to actually
		# look into the UNIX-style dir, we just switch them around.
		mkdir -p "${ED}"/usr/lib
		mv "${D}${fwdir}"/Versions/${PYVER}/lib/python${PYVER} \
			"${ED}"/usr/lib/python${PYVER}
		ln -s "${EPREFIX}"/usr/lib/python${PYVER} \
			"${D}${fwdir}"/Versions/${PYVER}/lib/
		# avoid framework incompatability, degrade to a normal UNIX lib
		mkdir -p "${ED}"/usr/$(get_libdir)
		cp "${D}${fwdir}"/Versions/${PYVER}/Python \
			"${ED}"/usr/$(get_libdir)/libpython${PYVER}.dylib
		chmod u+w "${ED}"/usr/$(get_libdir)/libpython${PYVER}.dylib
		install_name_tool \
			-id "${EPREFIX}"/usr/$(get_libdir)/libpython${PYVER}.dylib \
			"${ED}"/usr/$(get_libdir)/libpython${PYVER}.dylib
		chmod u-w "${ED}"/usr/$(get_libdir)/libpython${PYVER}.dylib
		cp "${S}"/libpython${PYVER}.a \
			"${ED}"/usr/$(get_libdir)/
		sed -i -e '/^LINKFORSHARED=/s/_PyMac_Error.*$/PyMac_Error/' \
			"${D}${fwdir}"/Versions/${PYVER}/lib/python${PYVER}/config/Makefile
		# remove unversioned files (that are not made versioned below)
		for f in python python-config pythonw ; do
			rm -f "${ED}"/usr/bin/${f}
		done
		rm -f "${ED}"/usr/bin/smtpd${PYVER}.py
		# add missing version.plist file
		mkdir -p "${D}${fwdir}"/Resources
		cat > "${D}${fwdir}"/Resources/version.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BuildVersion</key>
	<string>1</string>
	<key>CFBundleShortVersionString</key>
	<string>${PV}</string>
	<key>CFBundleVersion</key>
	<string>${PV}</string>
	<key>ProjectName</key>
	<string>Python</string>
	<key>SourceVersion</key>
	<string>${PV}</string>
</dict>
</plist>
EOF
	else
		emake DESTDIR="${D}" altinstall || die "emake altinstall failed"
	fi
	emake DESTDIR="${D}" maninstall || die "emake maninstall failed"

	mv "${ED}usr/bin/python${PYVER}-config" "${ED}usr/bin/python-config-${PYVER}"

	# Fix collisions between different slots of Python.
	mv "${ED}usr/bin/2to3" "${ED}usr/bin/2to3-${PYVER}"
	mv "${ED}usr/bin/pydoc" "${ED}usr/bin/pydoc${PYVER}"
	mv "${ED}usr/bin/idle" "${ED}usr/bin/idle${PYVER}"
	mv "${ED}usr/share/man/man1/python.1" "${ED}usr/share/man/man1/python${PYVER}.1"
	rm -f "${ED}usr/bin/smtpd.py"

	# Fix the OPT variable so that it doesn't have any flags listed in it.
	# Prevents the problem with compiling things with conflicting flags later.
	sed -e "s:^OPT=.*:OPT=-DNDEBUG:" -i "${ED}usr/$(get_libdir)/python${PYVER}/config/Makefile"

	# http://src.opensolaris.org/source/xref/jds/spec-files/trunk/SUNWPython.spec
	# These #defines cause problems when building c99 compliant python modules
	[[ ${CHOST} == *-solaris* ]] && dosed -e \
		's:^\(^#define \(_POSIX_C_SOURCE\|_XOPEN_SOURCE\|_XOPEN_SOURCE_EXTENDED\).*$\):/* \1 */:' \
		 /usr/include/python${PYVER}/pyconfig.h

	if use build; then
		rm -fr "${ED}usr/$(get_libdir)/python${PYVER}/"{bsddb,email,encodings,lib-tk,sqlite3,test}
	else
		use elibc_uclibc && rm -fr "${ED}usr/$(get_libdir)/python${PYVER}/"{bsddb/test,test}
		use berkdb || rm -fr "${ED}usr/$(get_libdir)/python${PYVER}/"{bsddb,test/test_bsddb*}
		use sqlite || rm -fr "${ED}usr/$(get_libdir)/python${PYVER}/"{sqlite3,test/test_sqlite*}
		use tk || rm -fr "${ED}usr/$(get_libdir)/python${PYVER}/lib-tk"
	fi

	use threads || rm -fr "${ED}usr/$(get_libdir)/python${PYVER}/multiprocessing"

	prep_ml_includes usr/include/python${PYVER}

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r "${S}"/Tools || die "doins failed"
	fi

	newinitd "${FILESDIR}/pydoc.init" pydoc-${SLOT}
	newconfd "${FILESDIR}/pydoc.conf" pydoc-${SLOT}

	# Installs empty directory.
	rmdir "${ED}usr/$(get_libdir)/${PN}${PYVER}/lib-old"
}

pkg_preinst() {
	if has_version "<${CATEGORY}/${PN}-${SLOT}" && ! has_version ">=${CATEGORY}/${PN}-${SLOT}_alpha"; then
		python_updater_warning="1"
	fi
}

pkg_postinst() {
	eselect python update --ignore 3.0 --ignore 3.1 --ignore 3.2

	python_mod_optimize -x "(site-packages|test)" /usr/lib/python${PYVER}
	[[ "$(get_libdir)" != "lib" ]] && python_mod_optimize -x "(site-packages|test)" /usr/$(get_libdir)/python${PYVER}

	if [[ "${python_updater_warning}" == "1" ]]; then
		ewarn
		ewarn "\e[1;31m************************************************************************\e[0m"
		ewarn
		ewarn "You have just upgraded from an older version of Python."
		ewarn "You should run 'python-updater' to rebuild Python modules."
		ewarn
		ewarn "\e[1;31m************************************************************************\e[0m"
		ewarn
		ebeep 12
	fi
}

pkg_postrm() {
	eselect python update --ignore 3.0 --ignore 3.1 --ignore 3.2

	python_mod_cleanup /usr/lib/python${PYVER}
	[[ "$(get_libdir)" != "lib" ]] && python_mod_cleanup /usr/$(get_libdir)/python${PYVER}
}
