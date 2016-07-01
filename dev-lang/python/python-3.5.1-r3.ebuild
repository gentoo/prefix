# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
WANT_LIBTOOL="none"

inherit autotools eutils flag-o-matic multilib pax-utils python-utils-r1 toolchain-funcs

MY_P="Python-${PV/_/}"
PATCHSET_VERSION="3.5.1-0"
PREFIX_PATCHREV="r2"

DESCRIPTION="An interpreted, interactive, object-oriented programming language"
HOMEPAGE="http://www.python.org/"
SRC_URI="http://www.python.org/ftp/python/${PV%_rc*}/${MY_P}.tar.xz
	https://dev.gentoo.org/~floppym/python/python-gentoo-patches-${PATCHSET_VERSION}.tar.xz
	https://dev.gentoo.org/~grobian/distfiles/python-prefix-${PV}-gentoo-patches-${PREFIX_PATCHREV}.tar.xz"

LICENSE="PSF-2"
SLOT="3.5/3.5m"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="aqua build elibc_uclibc examples gdbm hardened ipv6 libressl +ncurses +readline sqlite +ssl +threads tk wininst +xml"

# Do not add a dependency on dev-lang/python to this ebuild.
# If you need to apply a patch which requires python for bootstrapping, please
# run the bootstrap code on your dev box and include the results in the
# patchset. See bug 447752.

RDEPEND="app-arch/bzip2:0=
	app-arch/xz-utils:0=
	>=sys-libs/zlib-1.1.3:0=
	virtual/libffi
	virtual/libintl
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
	xml? ( >=dev-libs/expat-2.1:0= )
	!!<sys-apps/sandbox-2.6-r1"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	!sys-devel/gcc[libffi(-)]"
RDEPEND+=" !build? ( app-misc/mime-types )"
PDEPEND=">=app-eselect/eselect-python-20140125-r1"

S="${WORKDIR}/${MY_P}"

PYVER=${SLOT%/*}

src_prepare() {
	# Ensure that internal copies of expat, libffi and zlib are not used.
	rm -fr Modules/expat
	rm -fr Modules/_ctypes/libffi*
	rm -fr Modules/zlib

	if tc-is-cross-compiler; then
		# Invokes BUILDPYTHON, which is built for the host arch
		local EPATCH_EXCLUDE="*_regenerate_platform-specific_modules.patch"
	fi

	EPATCH_SUFFIX="patch" epatch "${WORKDIR}/patches"
	epatch "${FILESDIR}/${PN}-3.4.3-ncurses-pkg-config.patch"
	epatch "${FILESDIR}/3.5.1-cross-compile.patch"
	epatch "${FILESDIR}/${PN}-3.5-distutils-OO-build.patch"

	epatch_user

	# Prefix' round of patches
	# http://prefix.gentooexperimental.org:8000/python-patches-3_3
	EPATCH_EXCLUDE="${excluded_patches}" EPATCH_SUFFIX="patch" \
		epatch "${WORKDIR}"/python-prefix-${PV}-gentoo-patches-${PREFIX_PATCHREV}

	# https://forums.developer.apple.com/thread/9233, bug #572726
	sed -i -e '/$(RUNSHARED) .\/regen/s/^/export RUNSHARED=$(RUNSHARED); /' \
		Makefile.pre.in || die
	sed -i -e '/python$EXE/s/^/env ${RUNSHARED} /' \
		Lib/plat-darwin/regen || die

	# we provide a fully working readline also on Darwin, so don't force
	# usage of less functional libedit
	sed -i -e 's/__APPLE__/__NO_MUCKING_AROUND__/g' Modules/readline.c || die

	# We may have wrapped /usr/ccs/bin/nm on AIX for long TMPDIR.
	sed -i -e "/^NM=.*nm$/s,^.*$,NM=$(tc-getNM)," Modules/makexp_aix || die

	# Make sure python doesn't use the host libffi.
	use prefix && epatch "${FILESDIR}/python-3.2-libffi-pkgconfig.patch"

	sed -i -e "s:@@GENTOO_LIBDIR@@:$(get_libdir):g" \
		configure.ac \
		Lib/distutils/command/install.py \
		Lib/distutils/sysconfig.py \
		Lib/site.py \
		Lib/sysconfig.py \
		Lib/test/test_site.py \
		Makefile.pre.in \
		Modules/getpath.c \
		Modules/Setup.dist \
		setup.py || die "sed failed to replace @@GENTOO_LIBDIR@@"

	# workaround a development build env problem and muck around
	# framework install to get the best of both worlds (non-standard)
	sed -i \
		-e "s:FRAMEWORKINSTALLAPPSPREFIX=\":FRAMEWORKINSTALLAPPSPREFIX=\"${EPREFIX}:" \
		-e '/RUNSHARED=DYLD_FRAMEWORK_PATH/s/FRAMEWORK/LIBRARY/g' \
		configure.ac configure || die
	sed -i -e '/find/s/$/ || true/' Mac/PythonLauncher/Makefile.in || die

	# Disable ABI flags.
	sed -e "s/ABIFLAGS=\"\${ABIFLAGS}.*\"/:/" -i configure.ac || die "sed failed"

	eautoreconf
}

src_configure() {
	local disable
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

	# Export CC so even AIX will use gcc instead of xlc_r.
	# Export CXX so it ends up in /usr/lib/python3.X/config/Makefile.
	tc-export CC CXX

	# The configure script fails to use pkg-config correctly.
	# http://bugs.python.org/issue15506
	export ac_cv_path_PKG_CONFIG=$(tc-getPKG_CONFIG)

	# Set LDFLAGS so we link modules with -lpython3.2 correctly.
	# Needed on FreeBSD unless Python 3.2 is already installed.
	# Please query BSD team before removing this!
	append-ldflags "-L."

	# make sure setup.py considers Prefix' paths before system ones
	use prefix && append-cppflags -I"${EPREFIX}"/usr/include
	use prefix && append-ldflags -L"${EPREFIX}"/lib -L"${EPREFIX}"/usr/lib

	local dbmliborder
	if use gdbm; then
		dbmliborder+="${dbmliborder:+:}gdbm"
	fi

	BUILD_DIR="${WORKDIR}/${CHOST}"
	mkdir -p "${BUILD_DIR}" || die
	cd "${BUILD_DIR}" || die

	if use aqua ; then
		ECONF_SOURCE="${S}" OPT="" \
		econf \
			--enable-framework="${EPREFIX}"/usr/lib \
			--config-cache
	fi

	# pymalloc #452720
	local myeconfargs=(
		$(use aqua && echo --config-cache) \
		--with-fpectl
		--enable-shared
		$(use_enable ipv6)
		$(use_with threads)
		--infodir='${prefix}/share/info'
		--mandir='${prefix}/share/man'
		--with-computed-gotos
		--with-dbmliborder="${dbmliborder}"
		--with-libc=
		--enable-loadable-sqlite-extensions
		--without-ensurepip
		--with-system-expat
		--with-system-ffi
		--without-pymalloc
	)

	ECONF_SOURCE="${S}" OPT="" econf "${myeconfargs[@]}"

	if use threads && grep -q "#define POSIX_SEMAPHORES_NOT_ENABLED 1" pyconfig.h; then
		eerror "configure has detected that the sem_open function is broken."
		eerror "Please ensure that /dev/shm is mounted as a tmpfs with mode 1777."
		die "Broken sem_open function (bug 496328)"
	fi
}

src_compile() {
	cd "${BUILD_DIR}" || die

	emake CPPFLAGS= CFLAGS= LDFLAGS=

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
	local skipped_tests="gdb"

	for test in ${skipped_tests}; do
		mv "${S}"/Lib/test/test_${test}.py "${T}"
	done

	local -x PYTHONDONTWRITEBYTECODE=
	emake test EXTRATESTOPTS="-u-network" CPPFLAGS= CFLAGS= LDFLAGS= < /dev/tty
	local result=$?

	for test in ${skipped_tests}; do
		mv "${T}/test_${test}.py" "${S}"/Lib/test
	done

	elog "The following tests have been skipped:"
	for test in ${skipped_tests}; do
		elog "test_${test}.py"
	done

	elog "If you would like to run them, you may:"
	elog "cd '${EPREFIX}/usr/$(get_libdir)/python${PYVER}/test'"
	elog "and run the tests separately."

	if [[ ${result} -ne 0 ]]; then
		die "emake test failed"
	fi
}

src_install() {
	local libdir=${ED}/usr/$(get_libdir)/python${PYVER}

	cd "${BUILD_DIR}" || die

	emake DESTDIR="${D}" altinstall

	if use aqua ; then
		# avoid config.status to be triggered
		find Mac -name "Makefile" -exec touch \{\} + || die

		# Python_Launcher is kind of a wrapper, and we should fix it for
		# Prefix (it uses /usr/bin/pythonw) so useless
		# IDLE doesn't run, no idea, but definitely not used
		emake DESTDIR="${D}" -C Mac install_Python || die
		rmdir "${ED}"/Applications/Python* || die
		rmdir "${ED}"/Applications || die

		local fwdir=/usr/$(get_libdir)/Python.framework/Versions/${PYVER}
		ln -s "${EPREFIX}"/usr/include/python${PYVER} \
			"${ED}${fwdir}"/Headers || die
		ln -s "${EPREFIX}"/usr/lib/libpython${PYVER}.dylib \
			"${ED}${fwdir}"/Python || die
	fi

	sed \
		-e "s/\(CONFIGURE_LDFLAGS=\).*/\1/" \
		-e "s/\(PY_LDFLAGS=\).*/\1/" \
		-i "${libdir}/config-${PYVER}"*/Makefile || die "sed failed"

	# Fix collisions between different slots of Python.
	rm -f "${ED}usr/$(get_libdir)/libpython3.so"

	# Cheap hack to get version with ABIFLAGS
	local abiver=$(cd "${ED}usr/include"; echo python*)
	if [[ ${abiver} != python${PYVER} ]]; then
		# Replace python3.X with a symlink to python3.Xm
		rm "${ED}usr/bin/python${PYVER}" || die
		dosym "${abiver}" "/usr/bin/python${PYVER}"
		# Create python3.X-config symlink
		dosym "${abiver}-config" "/usr/bin/python${PYVER}-config"
		# Create python-3.5m.pc symlink
		dosym "python-${PYVER}.pc" "/usr/$(get_libdir)/pkgconfig/${abiver/${PYVER}/-${PYVER}}.pc"
	fi

	# python seems to get rebuilt in src_install (bug 569908)
	# Work around it for now.
	if has_version dev-libs/libffi[pax_kernel]; then
		pax-mark E "${ED}usr/bin/${abiver}"
	else
		pax-mark m "${ED}usr/bin/${abiver}"
	fi

	use elibc_uclibc && rm -fr "${libdir}/test"
	use sqlite || rm -fr "${libdir}/"{sqlite3,test/test_sqlite*}
	use tk || rm -fr "${ED}usr/bin/idle${PYVER}" "${libdir}/"{idlelib,tkinter,test/test_tk*}

	use threads || rm -fr "${libdir}/multiprocessing"
	use wininst || rm -f "${libdir}/distutils/command/"wininst-*.exe

	dodoc "${S}"/Misc/{ACKS,HISTORY,NEWS}

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		find "${S}"/Tools -name __pycache__ -print0 | xargs -0 rm -fr
		doins -r "${S}"/Tools
	fi
	insinto /usr/share/gdb/auto-load/usr/$(get_libdir) #443510
	if use aqua ; then
		# we do framework, so the emake trick below returns a pathname
		# since that won't work here, use a (cheap) trick instead
		local libname=libpython${PYVER}
	else
		local libname=$(printf 'e:\n\t@echo $(INSTSONAME)\ninclude Makefile\n' | \
			emake --no-print-directory -s -f - 2>/dev/null)
	fi
	newins "${S}"/Tools/gdb/libpython.py "${libname}"-gdb.py

	newconfd "${FILESDIR}/pydoc.conf" pydoc-${PYVER}
	newinitd "${FILESDIR}/pydoc.init" pydoc-${PYVER}
	sed \
		-e "s:@PYDOC_PORT_VARIABLE@:PYDOC${PYVER/./_}_PORT:" \
		-e "s:@PYDOC@:pydoc${PYVER}:" \
		-i "${ED}etc/conf.d/pydoc-${PYVER}" "${ED}etc/init.d/pydoc-${PYVER}" || die "sed failed"

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

	python_export "python${PYVER}" "${vars[@]}"
	echo "EPYTHON='${EPYTHON}'" > epython.py || die
	python_domodule epython.py

	# python-exec wrapping support
	local pymajor=${PYVER%.*}
	mkdir -p "${D}${PYTHON_SCRIPTDIR}" || die
	# python and pythonX
	ln -s "../../../bin/${abiver}" \
		"${D}${PYTHON_SCRIPTDIR}/python${pymajor}" || die
	ln -s "python${pymajor}" \
		"${D}${PYTHON_SCRIPTDIR}/python" || die
	# python-config and pythonX-config
	# note: we need to create a wrapper rather than symlinking it due
	# to some random dirname(argv[0]) magic performed by python-config
	cat > "${D}${PYTHON_SCRIPTDIR}/python${pymajor}-config" <<-EOF || die
		#!/bin/sh
		exec "${abiver}-config" "\${@}"
	EOF
	chmod +x "${D}${PYTHON_SCRIPTDIR}/python${pymajor}-config" || die
	ln -s "python${pymajor}-config" \
		"${D}${PYTHON_SCRIPTDIR}/python-config" || die
	# 2to3, pydoc, pyvenv
	ln -s "../../../bin/2to3-${PYVER}" \
		"${D}${PYTHON_SCRIPTDIR}/2to3" || die
	ln -s "../../../bin/pydoc${PYVER}" \
		"${D}${PYTHON_SCRIPTDIR}/pydoc" || die
	ln -s "../../../bin/pyvenv-${PYVER}" \
		"${D}${PYTHON_SCRIPTDIR}/pyvenv" || die
	# idle
	if use tk; then
		ln -s "../../../bin/idle${PYVER}" \
			"${D}${PYTHON_SCRIPTDIR}/idle" || die
	fi
}

pkg_preinst() {
	if has_version "<${CATEGORY}/${PN}-${PYVER}" && ! has_version ">=${CATEGORY}/${PN}-${PYVER}_alpha"; then
		python_updater_warning="1"
	fi
}

eselect_python_update() {
	if [[ -z "$(eselect python show)" || ! -f "${EROOT}usr/bin/$(eselect python show)" ]]; then
		eselect python update
	fi

	if [[ -z "$(eselect python show --python${PV%%.*})" || ! -f "${EROOT}usr/bin/$(eselect python show --python${PV%%.*})" ]]; then
		eselect python update --python${PV%%.*}
	fi
}

pkg_postinst() {
	eselect_python_update

	if [[ "${python_updater_warning}" == "1" ]]; then
		ewarn "You have just upgraded from an older version of Python."
		ewarn
		ewarn "Please adjust PYTHON_TARGETS (if so desired), and run emerge with the --newuse or --changed-use option to rebuild packages installing python modules."
	fi
}

pkg_postrm() {
	eselect_python_update
}
