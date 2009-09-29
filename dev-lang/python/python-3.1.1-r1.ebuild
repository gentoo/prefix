# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/python/python-3.1.1-r1.ebuild,v 1.6 2009/09/27 18:33:37 arfrever Exp $

EAPI="2"

inherit autotools eutils flag-o-matic multilib pax-utils python toolchain-funcs versionator

# We need this so that we don't depend on python.eclass.
PYVER_MAJOR=$(get_major_version)
PYVER_MINOR=$(get_version_component_range 2)
PYVER="${PYVER_MAJOR}.${PYVER_MINOR}"

MY_P="Python-${PV}"
S="${WORKDIR}/${MY_P}"

PATCHSET_REVISION="2"

DESCRIPTION="Python is an interpreted, interactive, object-oriented programming language."
HOMEPAGE="http://www.python.org/"
SRC_URI="http://www.python.org/ftp/python/${PV}/${MY_P}.tar.bz2
	mirror://gentoo/python-gentoo-patches-${PV}$([[ "${PATCHSET_REVISION}" != "0" ]] && echo "-r${PATCHSET_REVISION}").tar.bz2"

LICENSE="PSF-2.2"
SLOT="3.1"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="aqua build doc elibc_uclibc examples gdbm ipv6 +ncurses +readline sqlite ssl +threads tk ucs2 wininst +xml"

RDEPEND=">=app-admin/eselect-python-20090606
		>=sys-libs/zlib-1.1.3
		!build? (
			doc? ( dev-python/python-docs:${SLOT} )
			gdbm? ( sys-libs/gdbm )
			ncurses? (
				>=sys-libs/ncurses-5.2
				readline? ( >=sys-libs/readline-4.1 )
			)
			sqlite? ( >=dev-db/sqlite-3 )
			ssl? ( dev-libs/openssl )
			tk? ( >=dev-lang/tk-8.0 )
			xml? ( >=dev-libs/expat-2 )
		)
		!m68k? ( !m68k-mint? ( !mips? ( !sparc-fbsd? ( virtual/libffi ) ) ) )"
DEPEND="${RDEPEND}
		!m68k? ( !m68k-mint? ( !mips? ( !sparc-fbsd? ( dev-util/pkgconfig ) ) ) )"
RDEPEND+=" !build? ( app-misc/mime-types )"
PDEPEND="app-admin/python-updater
		=dev-lang/python-2*"

PROVIDE="virtual/python"

src_prepare() {
	if ! tc-is-cross-compiler; then
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
	use prefix && epatch "${FILESDIR}"/${P}-use-first-bsddb-found.patch
	epatch "${FILESDIR}"/${P}-readline-prefix.patch

	# build static for mint
	[[ ${CHOST} == *-mint* ]] && epatch "${FILESDIR}"/${P}-mint.patch

	# python defaults to using .so files, however they are bundles
	epatch "${FILESDIR}"/${PN}-2.5.1-darwin-bundle.patch
	# need this to have _NSGetEnviron being used, which by default isn't...
	[[ ${CHOST} == *-darwin* ]] && \
		append-flags -DWITH_NEXT_FRAMEWORK
	# but don't want framework path resulution stuff
	epatch "${FILESDIR}"/${P}-darwin-no-framework-lookup.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-darwin-gcc-version.patch
	# for Mac weenies
	epatch "${FILESDIR}"/${P}-mac.patch
	epatch "${FILESDIR}"/${P}-mac-64bits.patch
	epatch "${FILESDIR}"/${P}-mac-just-prefix.patch
	sed -i -e "s:@@APPLICATIONS_DIR@@:${EPREFIX}/Applications:g" \
		Mac/Makefile.in \
		Mac/IDLE/Makefile.in \
		Mac/Tools/Doc/setup.py \
		Mac/PythonLauncher/Makefile.in || die
	sed -i -e '/-DPREFIX=/s:$(prefix):'"${EPREFIX}"':' \
		-e '/-DEXEC_PREFIX=/s:$(exec_prefix):'"${EPREFIX}"':' \
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
	# don't try to build antique stuff
	epatch "${FILESDIR}"/${PN}-2.6.2-no-bsddb185.patch
	# this fails to compile on OpenSolaris at least, do we need it?
	epatch "${FILESDIR}"/${PN}-2.6.2-no-sunaudiodev.patch

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
		epatch "${FILESDIR}"/${P}-interix-nis.patch
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
		export PYTHON_DISABLE_MODULES="gdbm _curses _curses_panel readline _sqlite3 _tkinter _elementtree pyexpat"
		export PYTHON_DISABLE_SSL="1"
	else
		local disable
		use gdbm     || disable+=" gdbm"
		use ncurses  || disable+=" _curses _curses_panel"
		use readline || disable+=" readline"
		use sqlite   || disable+=" _sqlite3"
		use ssl      || export PYTHON_DISABLE_SSL="1"
		use tk       || disable+=" _tkinter"
		use xml      || disable+=" _elementtree pyexpat" # _elementtree uses pyexpat.
		use x64-macos && disable+=" Nav" # Carbon
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

	# Export CXX so it ends up in /usr/lib/python3.X/config/Makefile.
	tc-export CXX

	# Set LDFLAGS so we link modules with -lpython3.1 correctly.
	# Needed on FreeBSD unless Python 3.1 is already installed.
	# Please query BSD team before removing this!
	append-ldflags "-L."

	local dbmliborder
	if use gdbm; then
		dbmliborder+=":gdbm"
	fi
	dbmliborder="${dbmliborder#:}"

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

	if ! use m68k && ! use mips && ! use sparc-fbsd; then
		myconf+=" --with-system-ffi"
	fi

	econf \
		--with-fpectl \
		$(use_enable ipv6) \
		$(use_with threads) \
		$(use_with !ucs2 wide-unicode) \
		--infodir='${prefix}'/share/info \
		--mandir='${prefix}'/share/man \
		--with-libc='' \
		--with-dbmliborder=${dbmliborder} \
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
	local skip_tests="distutils"

	# test_debuglevel from test_telnetlib.py fails sometimes with
	# socket.error: [Errno 104] Connection reset by peer
	# http://bugs.python.org/issue6748
	skip_tests+=" telnetlib"

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
		local fwdir="${EPREFIX}"/usr/$(get_libdir)/Python.framework

		# let the makefiles do their thing
		emake -j1 CC="$(tc-getCC)" DESTDIR="${D}" STRIPFLAG= frameworkinstall || die "emake frameworkinstall failed"

		# avoid framework incompatability, degrade to a normal UNIX lib
		mkdir -p "${ED}"/usr/$(get_libdir)
		cp "${D}${fwdir}"/Versions/${PYVER}/Python \
			"${ED}"/usr/$(get_libdir)/libpython${PYVER}.dylib || die
		chmod u+w "${ED}"/usr/$(get_libdir)/libpython${PYVER}.dylib
		install_name_tool \
			-id "${EPREFIX}"/usr/$(get_libdir)/libpython${PYVER}.dylib \
			"${ED}"/usr/$(get_libdir)/libpython${PYVER}.dylib
		chmod u-w "${ED}"/usr/$(get_libdir)/libpython${PYVER}.dylib
		cp "${S}"/libpython${PYVER}.a \
			"${ED}"/usr/$(get_libdir)/ || die

		# rebuild python executable to be the non-pythonw (python wrapper)
		# version so we don't get framework crap
		$(tc-getCC) "${ED}"/usr/$(get_libdir)/libpython${PYVER}.dylib \
			-o "${ED}"/usr/bin/python${PYVER} \
			Modules/python.o || die

		# don't install the "Current" symlink, will always conflict
		rm "${D}${fwdir}"/Versions/Current || die
		# update whatever points to it, eselect-python sets them
		rm "${D}${fwdir}"/{Headers,Python,Resources} || die

		# remove unversioned files (that are not made versioned below)
		pushd "${ED}"/usr/bin > /dev/null
		rm -f python python-config python${PYVER}-config
		# python${PYVER} was created above
		for f in pythonw smtpd${PYVER}.py pydoc idle ; do
			rm -f ${f} ${f}${PYVER}
		done
		# pythonw needs to remain in the framework (that's the whole
		# reason we go through this framework hassle)
		ln -s ../lib/Python.framework/Versions/${PYVER}/bin/pythonw2.6 || die
		# copy the scripts to we can fix their shebangs
		for f in 2to3 pydoc${PYVER} idle${PYVER} python${PYVER}-config ; do
			cp "${D}${fwdir}"/Versions/${PYVER}/bin/${f} . || die
			sed -i -e '1c\#!'"${EPREFIX}"'/usr/bin/python'"${PYVER}" \
				${f} || die
		done
		# "fix" to have below collision fix not to bail
		mv pydoc${PYVER} pydoc || die
		mv idle${PYVER} idle || die
		popd > /dev/null

		# basically we don't like the framework stuff at all, so just move
		# stuff around or add some symlinks to make our life easier
		mkdir -p "${ED}"/usr
		mv "${D}${fwdir}"/Versions/${PYVER}/share \
			"${ED}"/usr/ || die "can't move share"
		# get includes just UNIX style
		mkdir -p "${ED}"/usr/include
		mv "${D}${fwdir}"/Versions/${PYVER}/include/python${PYVER} \
			"${ED}"/usr/include/ || die "can't move include"
		pushd "${D}${fwdir}"/Versions/${PYVER}/include > /dev/null
		ln -s ../../../../../include/python${PYVER} || die
		popd > /dev/null

		# same for libs
		# NOTE: can't symlink the entire dir, because a real dir already exists
		# on upgrade (site-packages), however since we h4x0rzed python to
		# actually look into the UNIX-style dir, we just switch them around.
		mkdir -p "${ED}"/usr/$(get_libdir)
		mv "${D}${fwdir}"/Versions/${PYVER}/lib/python${PYVER} \
			"${ED}"/usr/lib/ || die "can't move python${PYVER}"
		pushd "${D}${fwdir}"/Versions/${PYVER}/lib > /dev/null
		ln -s ../../../../python${PYVER} || die
		popd > /dev/null

		# fix up Makefile
		sed -i \
			-e '/^LINKFORSHARED=/s/_PyMac_Error.*$/PyMac_Error/' \
			-e '/^LDFLAGS=/s/=.*$/=/' \
			-e '/^prefix=/s:=.*$:= '"${EPREFIX}"'/usr:' \
			-e '/^PYTHONFRAMEWORK=/s/=.*$/=/' \
			-e '/^PYTHONFRAMEWORKDIR=/s/=.*$/= no-framework/' \
			-e '/^PYTHONFRAMEWORKPREFIX=/s/=.*$/=/' \
			-e '/^PYTHONFRAMEWORKINSTALLDIR=/s/=.*$/=/' \
			-e '/^LDLIBRARY=/s:=.*$:libpython$(VERSION).dylib:' \
			"${ED}"/usr/lib/python${PYVER}/config/Makefile || die

		# add missing version.plist file
		mkdir -p "${D}${fwdir}"/Versions/${PYVER}/Resources
		cat > "${D}${fwdir}"/Versions/${PYVER}/Resources/version.plist << EOF
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

	mv "${ED}usr/bin/python${PYVER}-config" "${ED}usr/bin/python-config-${PYVER}"

	# Fix collisions between different slots of Python.
	mv "${ED}usr/bin/2to3" "${ED}usr/bin/2to3-${PYVER}"
	mv "${ED}usr/bin/pydoc3" "${ED}usr/bin/pydoc${PYVER}"
	mv "${ED}usr/bin/idle3" "${ED}usr/bin/idle${PYVER}"
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
		rm -fr "${ED}usr/$(get_libdir)/python${PYVER}/"{email,sqlite3,test,tkinter}
	else
		use elibc_uclibc && rm -fr "${ED}usr/$(get_libdir)/python${PYVER}/test"
		use sqlite || rm -fr "${ED}usr/$(get_libdir)/python${PYVER}/"{sqlite3,test/test_sqlite*}
		use tk || rm -fr "${ED}usr/$(get_libdir)/python${PYVER}/"{tkinter,test/test_tk*}
	fi

	use threads || rm -fr "${ED}usr/$(get_libdir)/python${PYVER}/multiprocessing"

	prep_ml_includes usr/include/python${PYVER}

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r "${S}"/Tools || die "doins failed"
	fi

	newinitd "${FILESDIR}/pydoc.init" pydoc-${SLOT}
	newconfd "${FILESDIR}/pydoc.conf" pydoc-${SLOT}
}

pkg_preinst() {
	if has_version "<${CATEGORY}/${PN}-${SLOT}" && ! has_version ">=${CATEGORY}/${PN}-${SLOT}_alpha"; then
		# Delete this check after global switching to Python 3.
		if [[ "$(eselect python show)" == "python3."* ]]; then
			python_updater_warning="1"
		fi
	fi
}

eselect_python_update() {
	local ignored_python_slots
	[[ "$(eselect python show)" == "python2."* ]] && ignored_python_slots="--ignore 3.0 --ignore 3.1 --ignore 3.2"

	# Create python3 symlink.
	eselect python update > /dev/null

	eselect python update ${ignored_python_slots}
}

pkg_postinst() {
	eselect_python_update

	python_mod_optimize -x "(site-packages|test)" /usr/lib/python${PYVER}
	[[ "$(get_libdir)" != "lib" ]] && python_mod_optimize -x "(site-packages|test)" /usr/$(get_libdir)/python${PYVER}

	if [[ "$(eselect python show)" == "python2."* ]]; then
		ewarn
		ewarn "WARNING!"
		ewarn "Many Python modules haven't been ported yet to Python 3.*."
		ewarn "Python 3 hasn't been activated and Python wrapper is still configured to use Python 2."
		ewarn "You can manually activate Python ${SLOT} using \`eselect python set python${SLOT}\`."
		ewarn
		ebeep 6
	fi

	if [[ "${python_updater_warning}" == "1" ]]; then
		ewarn
		ewarn "\e[1;31m************************************************************************\e[0m"
		ewarn
		ewarn "You have just upgraded from an older version of Python."
		ewarn "You should run 'python-updater \${options}' to rebuild Python modules."
		ewarn
		ewarn "\e[1;31m************************************************************************\e[0m"
		ewarn
		ebeep 12
	fi
}

pkg_postrm() {
	eselect_python_update

	python_mod_cleanup /usr/lib/python${PYVER}
	[[ "$(get_libdir)" != "lib" ]] && python_mod_cleanup /usr/$(get_libdir)/python${PYVER}
}
