# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
WANT_LIBTOOL="none"

inherit autotools eutils flag-o-matic multilib pax-utils python-utils-r1 toolchain-funcs multiprocessing

MY_P="Python-${PV}"
PATCHSET_VERSION="2.7.11-0"
PREFIX_PATCHREV="r1"
CYGWINPORTS_GITREV="7be648659ef46f33db6913ca0ca5a809219d5629"

DESCRIPTION="An interpreted, interactive, object-oriented programming language"
HOMEPAGE="http://www.python.org/"
SRC_URI="http://www.python.org/ftp/python/${PV}/${MY_P}.tar.xz
	https://dev.gentoo.org/~djc/python-gentoo-patches-${PATCHSET_VERSION}.tar.xz
	https://dev.gentoo.org/~grobian/distfiles/python-prefix-${PV}-gentoo-patches-${PREFIX_PATCHREV}.tar.xz"

[[ -n ${CYGWINPORTS_GITREV} ]] &&
SRC_URI+=" elibc_Cygwin? ( https://github.com/cygwinports/python/archive/${CYGWINPORTS_GITREV}.zip )"

LICENSE="PSF-2"
SLOT="2.7"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="aqua -berkdb build doc elibc_uclibc examples gdbm hardened ipv6 libressl +ncurses +readline sqlite +ssl +threads tk +wide-unicode wininst +xml"

# Do not add a dependency on dev-lang/python to this ebuild.
# If you need to apply a patch which requires python for bootstrapping, please
# run the bootstrap code on your dev box and include the results in the
# patchset. See bug 447752.

RDEPEND="app-arch/bzip2:0=
	>=sys-libs/zlib-1.1.3:0=
	!m68k-mint? ( virtual/libffi )
	virtual/libintl
	berkdb? ( || (
		sys-libs/db:5.3
		sys-libs/db:5.2
		sys-libs/db:5.1
		sys-libs/db:5.0
		sys-libs/db:4.8
		sys-libs/db:4.7
		sys-libs/db:4.6
		sys-libs/db:4.5
		sys-libs/db:4.4
		sys-libs/db:4.3
		sys-libs/db:4.2
	) )
	gdbm? ( sys-libs/gdbm:0=[berkdb] )
	ncurses? (
		>=sys-libs/ncurses-5.2:0=
		readline? ( >=sys-libs/readline-4.1:0= )
	)
	sqlite? ( >=dev-db/sqlite-3.3.8:3= )
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:= )
	)
	tk? (
		>=dev-lang/tcl-8.0:0=
		>=dev-lang/tk-8.0:0=[-aqua]
		dev-tcltk/blt:0=
		dev-tcltk/tix
	)
	xml? ( >=dev-libs/expat-2.1 )
	!!<sys-apps/portage-2.1.9"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	>=sys-devel/autoconf-2.65
	!sys-devel/gcc[libffi]"
RDEPEND+=" !build? ( app-misc/mime-types )
	doc? ( dev-python/python-docs:${SLOT} )"
PDEPEND=">=app-eselect/eselect-python-20140125-r1
	app-admin/python-updater"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use berkdb; then
		ewarn "'bsddb' module is out-of-date and no longer maintained inside"
		ewarn "dev-lang/python. 'bsddb' and 'dbhash' modules have been additionally"
		ewarn "removed in Python 3. A maintained alternative of 'bsddb3' module"
		ewarn "is provided by dev-python/bsddb3."
	else
		if has_version "=${CATEGORY}/${PN}-${PV%%.*}*[berkdb]"; then
			ewarn "You are migrating from =${CATEGORY}/${PN}-${PV%%.*}*[berkdb]"
			ewarn "to =${CATEGORY}/${PN}-${PV%%.*}*[-berkdb]."
			ewarn "You might need to migrate your databases."
		fi
	fi
}

src_prepare() {
	# Ensure that internal copies of expat, libffi and zlib are not used.
	rm -r Modules/expat || die
	rm -r Modules/_ctypes/libffi* || die
	rm -r Modules/zlib || die

	if tc-is-cross-compiler; then
		local EPATCH_EXCLUDE="*_regenerate_platform-specific_modules.patch"
	fi

	EPATCH_SUFFIX="patch" epatch "${WORKDIR}/patches"

	# if building a patched source-tar, comment the rm's above, and uncomment
	# this line:
	#local EPATCH_EXCLUDE=" 01_all_prefix-no-patch-invention.patch"

	# Prefix' round of patches
	# http://prefix.gentooexperimental.org:8000/python-patches-2_7
	EPATCH_EXCLUDE="${excluded_patches}" EPATCH_SUFFIX="patch" \
		epatch "${WORKDIR}"/python-prefix-${PV}-gentoo-patches-${PREFIX_PATCHREV}

	if use aqua ; then
		# make sure we don't get a framework reference here
		sed -i -e '/-DPREFIX=/s:$(prefix):$(FRAMEWORKUNIXTOOLSPREFIX):' \
			-e '/-DEXEC_PREFIX=/s:$(exec_prefix):$(FRAMEWORKUNIXTOOLSPREFIX):' \
			Makefile.pre.in || die
		# Python upstream refuses to listen to configure arguments
		sed -i -e '/FRAMEWORKINSTALLAPPSPREFIX=/s:="[^"]*":="${prefix}/../Applications":' \
			configure.ac configure || die
		# we handle creation of symlinks in src_install
		sed -i -e '/ln -fs .*PYTHONFRAMEWORK/d' Makefile.pre.in || die
	fi
	# don't try to do fancy things on Darwin
	sed -i -e 's/__APPLE__/__NO_MUCKING_AROUND__/g' Modules/readline.c || die

	# Fix for cross-compiling.
	epatch "${FILESDIR}/python-2.7.5-nonfatal-compileall.patch"
	epatch "${FILESDIR}/python-2.7.9-ncurses-pkg-config.patch"
	epatch "${FILESDIR}/python-2.7.10-cross-compile-warn-test.patch"
	epatch "${FILESDIR}/python-2.7.10-system-libffi.patch"
	epatch "${FILESDIR}/python-3.4-pyfpe-dll.patch" # Cygwin: --with-fpectl

	# On AIX, we've wrapped /usr/ccs/bin/nm to work around long TMPDIR.
	sed -i -e "/^NM=.*nm$/s,^.*$,NM=$(tc-getNM)," Modules/makexp_aix || die

	# Make sure python doesn't use the host libffi.
	use prefix && epatch "${FILESDIR}/python-2.7-libffi-pkgconfig.patch"

	if [[ -n ${CYGWINPORTS_GITREV} ]] && use elibc_Cygwin; then
	    local p d="${WORKDIR}/python-${CYGWINPORTS_GITREV}"
	    for p in $(
		    eval "$(sed -ne '/PATCH_URI="/,/"/p' < "${d}"/python.cygport)"
		    echo ${PATCH_URI}
	    ); do
			# dropped by 01_all_prefix-no-patch-invention.patch
			[[ ${p} == *-tkinter-* ]] && continue
		    epatch "${d}/${p}"
	    done
	fi

	epatch_user

	sed -i -e "s:@@GENTOO_LIBDIR@@:$(get_libdir):g" \
		Lib/distutils/command/install.py \
		Lib/distutils/sysconfig.py \
		Lib/site.py \
		Lib/sysconfig.py \
		Lib/test/test_site.py \
		Makefile.pre.in \
		Modules/Setup.dist \
		Modules/getpath.c \
		setup.py || die "sed failed to replace @@GENTOO_LIBDIR@@"

	eautoreconf
}

src_configure() {
		# dbm module can be linked against berkdb or gdbm.
		# Defaults to gdbm when both are enabled, #204343.
		local disable
		use berkdb   || use gdbm || disable+=" dbm"
		use berkdb   || disable+=" _bsddb"
		use gdbm     || disable+=" gdbm"
		use ncurses  || disable+=" _curses _curses_panel"
		use readline || disable+=" readline"
		use sqlite   || disable+=" _sqlite3"
		use ssl      || export PYTHON_DISABLE_SSL="1"
		use tk       || disable+=" _tkinter"
		use xml      || disable+=" _elementtree pyexpat" # _elementtree uses pyexpat.
		[[ ${CHOST} == *64-apple-darwin* ]] && disable+=" Nav _Qt" # Carbon
		[[ ${CHOST} == *-apple-darwin11 ]] && disable+=" _Fm _Qd _Qdoffs"
		export PYTHON_DISABLE_MODULES="${disable}"

		if ! use xml; then
			ewarn "You have configured Python without XML support."
			ewarn "This is NOT a recommended configuration as you"
			ewarn "may face problems parsing any XML documents."
		fi

	if [[ -n "${PYTHON_DISABLE_MODULES}" ]]; then
		einfo "Disabled modules: ${PYTHON_DISABLE_MODULES}"
	fi

	if [[ "$(gcc-major-version)" -ge 4 ]]; then
		append-flags -fwrapv
	fi

	filter-flags -malign-double

	# https://bugs.gentoo.org/show_bug.cgi?id=50309
	if is-flagq -O3; then
		is-flagq -fstack-protector-all && replace-flags -O3 -O2
		use hardened && replace-flags -O3 -O2
	fi

	if tc-is-cross-compiler; then
		# Force some tests that try to poke fs paths.
		export ac_cv_file__dev_ptc=no
		export ac_cv_file__dev_ptmx=yes
	fi

	# http://bugs.gentoo.org/show_bug.cgi?id=302137
	if [[ ${CHOST} == powerpc-*-darwin* ]] && \
		( is-flag "-mtune=*" || is-flag "-mcpu=*" ) || \
		[[ ${CHOST} == powerpc64-*-darwin* ]];
	then
		replace-flags -O2 -O3
		replace-flags -Os -O3  # comment #14
	fi

	# Set LDFLAGS so we link modules with -lpython2.7 correctly.
	# Needed on FreeBSD unless Python 2.7 is already installed.
	# Please query BSD team before removing this!
	# On AIX this is not needed, but would record '.' as runpath.
	[[ ${CHOST} == *-aix* ]] ||
	append-ldflags "-L."

	if use prefix ; then
		# for Python's setup.py not to do false assumptions (only looking in
		# host paths) we need to make explicit where Prefix stuff is
		append-cppflags -I"${EPREFIX}"/usr/include
		append-ldflags -L"${EPREFIX}"/$(get_libdir)
		append-ldflags -L"${EPREFIX}"/usr/$(get_libdir)
		# fix compilation on some 64-bits Linux hosts, #381163, #473520
		for hostlibdir in /usr/lib32 /usr/lib64 /usr/lib /lib32 /lib64; do
			[[ -d ${hostlibdir} ]] || continue
			append-ldflags -L${hostlibdir}
		done
		# Have to move $(CPPFLAGS) to before $(CFLAGS) to ensure that
		# local include paths - set in $(CPPFLAGS) - are searched first.
		sed -i -e "/^PY_CFLAGS[ \\t]*=/s,\\\$(CFLAGS)[ \\t]*\\\$(CPPFLAGS),\$(CPPFLAGS) \$(CFLAGS)," Makefile.pre.in || die
	fi

	# Export CC so even AIX will use gcc instead of xlc_r.
	# Export CXX so it ends up in /usr/lib/python2.X/config/Makefile.
	tc-export CC CXX
	# The configure script fails to use pkg-config correctly.
	# http://bugs.python.org/issue15506
	export ac_cv_path_PKG_CONFIG=$(tc-getPKG_CONFIG)

	local dbmliborder
	if use gdbm; then
		dbmliborder+="${dbmliborder:+:}gdbm"
	fi
	if use berkdb; then
		dbmliborder+="${dbmliborder:+:}bdb"
	fi

	[[ ${CHOST} == *-mint* ]] && export ac_cv_func_poll=no

	# we need this to get pythonw, the GUI version of python
	# --enable-framework and --enable-shared are mutually exclusive:
	# http://bugs.python.org/issue5809
	local myshared=
	use aqua \
		&& myshared="--enable-framework=${EPREFIX}/usr/lib" \
		|| myshared="--enable-shared"

	BUILD_DIR="${WORKDIR}/${CHOST}"
	mkdir -p "${BUILD_DIR}" || die
	cd "${BUILD_DIR}" || die

	# note: for a framework build we need to use ucs2 because OSX
	# uses that internally too:
	# http://bugs.python.org/issue763708
	# HAS_HG to avoid finding obsolete hg of the host
	ECONF_SOURCE="${S}" OPT="" HAS_HG="no" \
	econf \
		--with-fpectl \
		${myshared} \
		$(use_enable ipv6) \
		$(use_with threads) \
		$( (use wide-unicode && use !aqua) && echo "--enable-unicode=ucs4" || echo "--enable-unicode=ucs2") \
		--infodir='${prefix}/share/info' \
		--mandir='${prefix}/share/man' \
		--with-computed-gotos \
		--with-dbmliborder="${dbmliborder}" \
		--with-libc="" \
		--enable-loadable-sqlite-extensions \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip

	if use threads && grep -q "#define POSIX_SEMAPHORES_NOT_ENABLED 1" pyconfig.h; then
		eerror "configure has detected that the sem_open function is broken."
		eerror "Please ensure that /dev/shm is mounted as a tmpfs with mode 1777."
		die "Broken sem_open function (bug 496328)"
	fi
}

src_compile() {
	# Avoid invoking pgen for cross-compiles.
	touch Include/graminit.h Python/graminit.c

	cd "${BUILD_DIR}" || die
	emake

	# Work around bug 329499. See also bug 413751 and 457194.
	if has_version dev-libs/libffi[pax_kernel]; then
		pax-mark E python
	else
		pax-mark m python
	fi
}

src_test() {
	# Tests will not work when cross compiling.
	if tc-is-cross-compiler; then
		elog "Disabling tests due to crosscompiling."
		return
	fi

	cd "${BUILD_DIR}" || die

	# Skip failing tests.
	local skipped_tests="distutils gdb"

	for test in ${skipped_tests}; do
		mv "${S}"/Lib/test/test_${test}.py "${T}"
	done

	# Rerun failed tests in verbose mode (regrtest -w).
	emake test EXTRATESTOPTS="-w" < /dev/tty
	local result="$?"

	for test in ${skipped_tests}; do
		mv "${T}/test_${test}.py" "${S}"/Lib/test
	done

	elog "The following tests have been skipped:"
	for test in ${skipped_tests}; do
		elog "test_${test}.py"
	done

	elog "If you would like to run them, you may:"
	elog "cd '${EPREFIX}/usr/$(get_libdir)/python${SLOT}/test'"
	elog "and run the tests separately."

	if [[ "${result}" -ne 0 ]]; then
		die "emake test failed"
	fi
}

src_install() {
	local libdir=${ED}/usr/$(get_libdir)/python${SLOT}

	cd "${BUILD_DIR}" || die
	[[ ${CHOST} == *-mint* ]] && keepdir /usr/lib/python${SLOT}/lib-dynload/
	if use aqua ; then
		local fwdir="${EPREFIX}"/usr/$(get_libdir)/Python.framework

		# do not make multiple targets in parallel when there are broken
		# sharedmods (during bootstrap), would build them twice in parallel.

		# Python_Launcher is kind of a wrapper, and we should fix it for
		# Prefix (it uses /usr/bin/pythonw) so useless
		# IDLE doesn't run, no idea, but definitely not used
		sed -i -e 's/install_\(BuildApplet\|PythonLauncher\|IDLE\)[^:]//g' \
			Mac/Makefile || die

		# let the makefiles do their thing
		emake -j1 CC="$(tc-getCC)" DESTDIR="${D}" STRIPFLAG= altinstall
		rmdir "${ED}"/Applications/Python* || die
		rmdir "${ED}"/Applications || die

		# avoid framework incompatability, degrade to a normal UNIX lib
		mkdir -p "${ED}"/usr/$(get_libdir)
		cp "${D}${fwdir}"/Versions/${SLOT}/Python \
			"${ED}"/usr/$(get_libdir)/libpython${SLOT}.dylib || die
		chmod u+w "${ED}"/usr/$(get_libdir)/libpython${SLOT}.dylib
		install_name_tool \
			-id "${EPREFIX}"/usr/$(get_libdir)/libpython${SLOT}.dylib \
			"${ED}"/usr/$(get_libdir)/libpython${SLOT}.dylib
		chmod u-w "${ED}"/usr/$(get_libdir)/libpython${SLOT}.dylib
		cp libpython${SLOT}.a "${ED}"/usr/$(get_libdir)/ || die

		# rebuild python executable to be the non-pythonw (python wrapper)
		# version so we don't get framework crap
		rm "${ED}"/usr/bin/python${SLOT}  # drop existing symlink, bug #390861
		$(tc-getCC) "${ED}"/usr/$(get_libdir)/libpython${SLOT}.dylib \
			-o "${ED}"/usr/bin/python${SLOT} \
			Modules/python.o || die

		# don't install the "Current" symlink, will always conflict
		rm "${D}${fwdir}"/Versions/Current || die
		# update whatever points to it, eselect-python sets them
		rm "${D}${fwdir}"/{Headers,Python,Resources} || die

		# remove unversioned files (that are not made versioned below)
		pushd "${ED}"/usr/bin > /dev/null
		rm -f python python-config python${SLOT}-config
		# python${SLOT} was created above
		for f in pythonw smtpd${SLOT}.py pydoc idle ; do
			rm -f ${f} ${f}${SLOT}
		done
		# pythonw needs to remain in the framework (that's the whole
		# reason we go through this framework hassle)
		ln -s ../lib/Python.framework/Versions/${SLOT}/bin/pythonw${SLOT} || die
		# copy the scripts to we can fix their shebangs
		for f in 2to3 pydoc${SLOT} idle${SLOT} python${SLOT}-config ; do
			# for some reason sometimes they already exist, bug #347321
			rm -f ${f}
			cp "${D}${fwdir}"/Versions/${SLOT}/bin/${f} . || die
			sed -i -e '1c\#!'"${EPREFIX}"'/usr/bin/python'"${SLOT}" \
				${f} || die
		done
		# "fix" to have below collision fix not to bail
		mv pydoc${SLOT} pydoc || die
		mv idle${SLOT} idle || die
		popd > /dev/null

		# basically we don't like the framework stuff at all, so just move
		# stuff around or add some symlinks to make our life easier
		mkdir -p "${ED}"/usr
		mv "${D}${fwdir}"/Versions/${SLOT}/share \
			"${ED}"/usr/ || die "can't move share"
		# get includes just UNIX style
		mkdir -p "${ED}"/usr/include
		mv "${D}${fwdir}"/Versions/${SLOT}/include/python${SLOT} \
			"${ED}"/usr/include/ || die "can't move include"
		pushd "${D}${fwdir}"/Versions/${SLOT}/include > /dev/null
		ln -s ../../../../../include/python${SLOT} || die
		popd > /dev/null
		rm -f "${ED}"/usr/share/man/man1/python{,2}.1

		# same for libs
		# NOTE: can't symlink the entire dir, because a real dir already exists
		# on upgrade (site-packages), however since we h4x0rzed python to
		# actually look into the UNIX-style dir, we just switch them around.
		mkdir -p "${ED}"/usr/$(get_libdir)/python${SLOT}
		mv "${D}${fwdir}"/Versions/${SLOT}/lib/python${SLOT}/* \
			"${ED}"/usr/$(get_libdir)/python${SLOT}/ \
			|| die "can't move python${SLOT}"
		rmdir "${D}${fwdir}"/Versions/${SLOT}/lib/python${SLOT} || die
		pushd "${D}${fwdir}"/Versions/${SLOT}/lib > /dev/null
		ln -s ../../../../python${SLOT} || die
		popd > /dev/null

		# fix up Makefile
		sed -i \
			-e '/^LINKFORSHARED=/s/-u _PyMac_Error.*$//' \
			-e '/^LDFLAGS=/s/=.*$/=/' \
			-e '/^prefix=/s:=.*$:= '"${EPREFIX}"'/usr:' \
			-e '/^PYTHONFRAMEWORK=/s/=.*$/=/' \
			-e '/^PYTHONFRAMEWORKDIR=/s/=.*$/= no-framework/' \
			-e '/^PYTHONFRAMEWORKPREFIX=/s/=.*$/=/' \
			-e '/^PYTHONFRAMEWORKINSTALLDIR=/s/=.*$/=/' \
			-e '/^LDLIBRARY=/s:=.*$:libpython$(VERSION).dylib:' \
			"${libdir}"/config/Makefile || die
		# and sysconfigdata likewise
		sed -i \
			-e "/'LINKFORSHARED'/s/-u _PyMac_Error[^']*'/'/" \
			-e "/'LDFLAGS'/s/:.*$/:'',/" \
			-e "/'prefix'/s|:.*$|:'${EPREFIX}/usr',|" \
			-e "/'PYTHONFRAMEWORK'/s/:.*$/:'',/" \
			-e "/'PYTHONFRAMEWORKDIR'/s/:.*$/:'no-framework',/" \
			-e "/'PYTHONFRAMEWORKPREFIX'/s/:.*$/:'',/" \
			-e "/'PYTHONFRAMEWORKINSTALLDIR'/s/:.*$/:'',/" \
			-e "/'LDLIBRARY'/s|:.*$|:'libpython${SLOT}.dylib',|" \
			"${libdir}"/_sysconfigdata.py || die

		# add missing version.plist file
		mkdir -p "${D}${fwdir}"/Versions/${SLOT}/Resources
		cat > "${D}${fwdir}"/Versions/${SLOT}/Resources/version.plist << EOF
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
		emake DESTDIR="${D}" altinstall
	fi

	sed -e "s/\(LDFLAGS=\).*/\1/" -i "${libdir}/config/Makefile" || die "sed failed"
	if [[ ${CHOST} == *-aix* ]]; then
		# fix upstream bugs with quite large proposed diffs still to be sorted out:
		# http://bugs.python.org/issue13493
		# http://bugs.python.org/issue14150
		# http://bugs.python.org/issue15590
		# http://bugs.python.org/issue16189
		sed -e "/Libs:/s|\$| -Wl,-bE:${EPREFIX}/${libdir#$ED}/config/python.exp -lld|" \
			-i "${ED}"usr/$(get_libdir)/pkgconfig/python-${SLOT}.pc || die "sed failed"
		sed -e "s|:Modules/python.exp|:${EPREFIX}/${libdir#$ED}/config/python.exp|" \
			-e 's| -bI:| -Wl,-bI:|g' \
			-e '/LINKFORSHARED/s|-bE:|-bI:|g' \
			-e '/LINKFORSHARED/s| -lld||g' \
			-i "${libdir}"/{_sysconfigdata.py,config/Makefile} || die "sed failed"
	fi

	# Fix collisions between different slots of Python.
	mv "${ED}usr/bin/2to3" "${ED}usr/bin/2to3-${SLOT}"
	mv "${ED}usr/bin/pydoc" "${ED}usr/bin/pydoc${SLOT}"
	mv "${ED}usr/bin/idle" "${ED}usr/bin/idle${SLOT}"
	rm -f "${ED}usr/bin/smtpd.py"

	# http://src.opensolaris.org/source/xref/jds/spec-files/trunk/SUNWPython.spec
	# These #defines cause problems when building c99 compliant python modules
	# http://bugs.python.org/issue1759169
	[[ ${CHOST} == *-solaris* ]] && sed -i -e \
		's:^\(^#define \(_POSIX_C_SOURCE\|_XOPEN_SOURCE\|_XOPEN_SOURCE_EXTENDED\).*$\):/* \1 */:' \
		 "${ED}"/usr/include/python${SLOT}/pyconfig.h

		use berkdb || rm -r "${libdir}/"{bsddb,dbhash.py,test/test_bsddb*} || die
		use sqlite || rm -r "${libdir}/"{sqlite3,test/test_sqlite*} || die
		use tk || rm -r "${ED}usr/bin/idle${SLOT}" "${libdir}/"{idlelib,lib-tk} || die
		use elibc_uclibc && rm -fr "${libdir}/"{bsddb/test,test}

	use threads || rm -r "${libdir}/multiprocessing" || die
	use wininst || rm -r "${libdir}/distutils/command/"wininst-*.exe || die

	dodoc "${S}"/Misc/{ACKS,HISTORY,NEWS}

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r "${S}"/Tools
	fi
	insinto /usr/share/gdb/auto-load/usr/$(get_libdir) #443510
	local libname
	if use aqua ; then
		# we do framework, so the emake trick below returns a pathname
		# since that won't work here, use a (cheap) trick instead
		libname=libpython${SLOT}
	else
		libname=$(printf 'e:\n\t@echo $(INSTSONAME)\ninclude Makefile\n' | \
			emake --no-print-directory -s -f - 2>/dev/null)
	fi
	newins "${S}"/Tools/gdb/libpython.py "${libname}"-gdb.py

	newconfd "${FILESDIR}/pydoc.conf" pydoc-${SLOT}
	newinitd "${FILESDIR}/pydoc.init" pydoc-${SLOT}
	sed \
		-e "s:@PYDOC_PORT_VARIABLE@:PYDOC${SLOT/./_}_PORT:" \
		-e "s:@PYDOC@:pydoc${SLOT}:" \
		-i "${ED}etc/conf.d/pydoc-${SLOT}" "${ED}etc/init.d/pydoc-${SLOT}" || die "sed failed"

	# for python-exec
	local vars=( EPYTHON PYTHON_SITEDIR PYTHON_SCRIPTDIR )

	# if not using a cross-compiler, use the fresh binary
	if ! tc-is-cross-compiler; then
		local -x PYTHON=./python$(sed -n '/BUILDEXE=/s/^.*=\s\+//p' Makefile)
		local -x LD_LIBRARY_PATH=${LD_LIBRARY_PATH+${LD_LIBRARY_PATH}:}.
		local -x DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH+${DYLD_LIBRARY_PATH}:}.
	else
		vars=( PYTHON "${vars[@]}" )
	fi

	python_export "python${SLOT}" "${vars[@]}"
	echo "EPYTHON='${EPYTHON}'" > epython.py || die
	python_domodule epython.py

	# python-exec wrapping support
	local pymajor=${SLOT%.*}
	mkdir -p "${D}${PYTHON_SCRIPTDIR}" || die
	# python and pythonX
	ln -s "../../../bin/python${SLOT}" \
		"${D}${PYTHON_SCRIPTDIR}/python${pymajor}" || die
	ln -s "python${pymajor}" \
		"${D}${PYTHON_SCRIPTDIR}/python" || die
	# python-config and pythonX-config
	ln -s "../../../bin/python${SLOT}-config" \
		"${D}${PYTHON_SCRIPTDIR}/python${pymajor}-config" || die
	ln -s "python${pymajor}-config" \
		"${D}${PYTHON_SCRIPTDIR}/python-config" || die
	# 2to3, pydoc, pyvenv
	ln -s "../../../bin/2to3-${SLOT}" \
		"${D}${PYTHON_SCRIPTDIR}/2to3" || die
	ln -s "../../../bin/pydoc${SLOT}" \
		"${D}${PYTHON_SCRIPTDIR}/pydoc" || die
	# idle
	if use tk; then
		ln -s "../../../bin/idle${SLOT}" \
			"${D}${PYTHON_SCRIPTDIR}/idle" || die
	fi
}

pkg_preinst() {
	if has_version "<${CATEGORY}/${PN}-${SLOT}" && ! has_version "${CATEGORY}/${PN}:2.7"; then
		python_updater_warning="1"
	fi
}

eselect_python_update() {
	if [[ -z "$(eselect python show)" || ! -f "${EROOT}usr/bin/$(eselect python show)" ]]; then
		eselect python update
	fi
}

pkg_postinst() {
	eselect_python_update

	if [[ "${python_updater_warning}" == "1" ]]; then
		ewarn "You have just upgraded from an older version of Python."
		ewarn "You should switch active version of Python ${PV%%.*} and run"
		ewarn "'python-updater [options]' to rebuild Python modules."
	fi
}

pkg_postrm() {
	eselect_python_update
}
