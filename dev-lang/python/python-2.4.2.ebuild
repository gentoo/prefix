# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/python/python-2.4.2.ebuild,v 1.6 2005/10/13 17:40:54 metalgod Exp $

EAPI="prefix"

# NOTE about python-portage interactions :
# - Do not add a pkg_setup() check for a certain version of portage
#   in dev-lang/python. It _WILL_ stop people installing from
#   Gentoo 1.4 images.

inherit eutils flag-o-matic python multilib versionator toolchain-funcs

# we need this so that we don't depends on python.eclass
PYVER_MAJOR=$(get_major_version)
PYVER_MINOR=$(get_version_component_range 2)
PYVER="${PYVER_MAJOR}.${PYVER_MINOR}"

MY_P="Python-${PV}"
S="${WORKDIR}/${MY_P}"
DESCRIPTION="Python is an interpreted, interactive, object-orientated programming language."
HOMEPAGE="http://www.python.org/"
SRC_URI="http://www.python.org/ftp/python/${PV}/${MY_P}.tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.4"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="ncurses gdbm ssl readline tcltk berkdb bootstrap ipv6 build ucs2 doc X nocxx aqua framework"

DEPEND=">=sys-libs/zlib-1.1.3
	!dev-python/cjkcodecs
	!build? (
		X? ( tcltk? ( >=dev-lang/tk-8.0 ) )
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

PDEPEND="${DEPEND} 	dev-python/python-fchksum"

PROVIDE="virtual/python"

src_unpack() {
	unpack ${A}
	cd ${S}

	# unnecessary termcap dep in readline (#79013)
	epatch ${FILESDIR}/${PN}-2.4.2-readline.patch
	# db4.2 support
	epatch ${FILESDIR}/${PN}-2.4.1-db4.patch

	# adds support for PYTHON_DONTCOMPILE shell environment to
	# supress automatic generation of .pyc and .pyo files - liquidx (08 Oct 03)
	epatch ${FILESDIR}/${PN}-${PYVER}-gentoo_py_dontcompile.patch
	epatch ${FILESDIR}/${PN}-${PYVER}-disable_modules_and_ssl.patch
	epatch ${FILESDIR}/${PN}-${PYVER}-mimetypes_apache.patch

	# prepends /usr/lib/portage/pym to sys.path
	epatch ${FILESDIR}/${PN}-${PYVER}-add_portage_search_path.patch

	epatch ${FILESDIR}/${PN}-2.4.1-libdir.patch
	sed -i -e "s:@@GENTOO_LIBDIR@@:$(get_libdir):g" \
		Lib/distutils/command/install.py \
		Lib/distutils/sysconfig.py \
		Lib/site.py \
		Makefile.pre.in \
		Modules/Setup.dist \
		Modules/getpath.c \
		setup.py || die

	# add support for struct stat st_flags attribute (bug 94637)
	epatch ${FILESDIR}/python-2.4.1-st_flags.patch

	if tc-is-cross-compiler ; then
		epatch "${FILESDIR}"/python-2.4.1-bindir-libdir.patch
		epatch "${FILESDIR}"/python-2.4.1-crosscompile.patch
	fi

	epatch ${FILESDIR}/${PN}-2.4.1-dylib.patch
	epatch ${FILESDIR}/${PN}-2.4.1-darwin-configure.patch
	epatch ${FILESDIR}/${PN}-2.4.1-darwin-tk.patch
	epatch ${FILESDIR}/${PN}-2.4.1-darwin-pyport.patch
	sed -i -e "s:/usr/local:/usr:g" Mac/OSX/Makefile \
		|| die "sed Mac/OSX/Makefile failed"
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
		( use !X || use !tcltk ) \
			&& PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} _tkinter"
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

	if [[ ${USERLAND} != "Darwin" ]] ; then
		myconf="${myconf} --disable-toolbox-glue"
	fi

	src_configure

	if tc-is-cross-compiler ; then
		OPT="-O1" LDFLAGS="" \
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

	tc-export CXX
	econf \
		--with-fpectl \
		--enable-shared \
		$(use_enable ipv6) \
		$(use_enable framework) \
		--with-threads \
		--with-libc='' \
		${myconf} || die
	emake || die "Parallel make failed"
}

src_install() {
	dodir /usr
	src_configure

	if use framework ; then
		local myfw
		myfw="Library/Frameworks/Python.framework/Versions/${PYVER}"
		make DESTDIR="${D}" frameworkinstall || die "framework failed"
		if use aqua ; then
			make DESTDIR="${D}" frameworkinstallapps || die "install apps failed"
			make DESTDIR="${D}" frameworkinstallextras || die "install extras failed"
		fi
		dodir /usr/{include,lib}
		dosym ../../${myfw}/lib/libpython.2.4.2.dylib /usr/lib/libpython.2.4.2.dylib
		dosym ../../${myfw}/lib/python${PYVER} /usr/lib/python${PYVER}
		dosym ../../${myfw}/include/python${PYVER} /usr/include/python${PYVER}
	else
		make DESTDIR="${D}" altinstall  || die "make altinstall failed"
	fi

	if use userland_Darwin && ! use framework; then
		make libpython.${PV}.dylib || die "make dylib failed"
		into /usr
		dolib.so ${S}/libpython.2.4.2.dylib
		cd ${ED}
		dosym /usr/lib/libpython.${PV}.dylib /usr/lib/libpython.2.4.dylib
		dosym /usr/lib/libpython.${PV}.dylib /usr/lib/libpython.2.dylib
		dosym /usr/lib/libpython.${PV}.dylib /usr/lib/libpython.dylib
	fi

	# install our own custom python-config
	exeinto /usr/bin
	newexe ${FILESDIR}/python-config-${PYVER} python-config

	# Use correct libdir in python-config
	dosed "s:/usr/lib/:${EPREFIX}/usr/$(get_libdir)/:" /usr/bin/python-config

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

	# install python-updater in /usr/sbin
	dosbin ${FILESDIR}/python-updater

	if use build ; then
		rm -rf ${ED}/usr/lib/python${PYVER}/{test,encodings,email,lib-tk,bsddb/test}
	else
		use elibc_uclibc && rm -rf ${ED}/usr/lib/python${PYVER}/{test,bsddb/test}
		use berkdb || rm -rf ${ED}/usr/lib/python${PYVER}/bsddb
		( use !X || use !tcltk ) && rm -rf ${ED}/usr/lib/python${PYVER}/lib-tk
	fi

	prep_ml_includes /usr/include/python${PYVER}
}

pkg_postrm() {
	python_makesym
	python_mod_cleanup /usr/lib/python${PYVER}
	[[ "$(get_libdir)" == "lib" ]] || python_mod_cleanup /usr/$(get_libdir)/python${PYVER}
}

pkg_postinst() {
	local myroot
	myroot=${PROOT%/}

	python_makesym
	python_mod_optimize
	python_mod_optimize -x site-packages -x test ${myroot}/usr/lib/python${PYVER}
	[[ "$(get_libdir)" == "lib" ]] || python_mod_optimize -x site-packages -x test ${myroot}/usr/$(get_libdir)/python${PYVER}


	# workaround possible python-upgrade-breaks-portage situation
	if [ ! -f ${myroot}/usr/lib/portage/pym/portage.py ]; then
		if [ -f ${myroot}/usr/lib/python2.3/site-packages/portage.py ]; then
			einfo "Working around possible python-portage upgrade breakage"
			mkdir -p ${myroot}/usr/lib/portage/pym
			cp ${myroot}/usr/lib/python2.4/site-packages/{portage,xpak,output,cvstree,getbinpkg,emergehelp,dispatch_conf}.py ${myroot}/usr/lib/portage/pym
			python_mod_optimize ${EPREFIX}/usr/lib/portage/pym
		fi
	fi

	# try to upgrade to new python automatically - something to think about
	#if [ "${EROOT}" = "/" ]; then
	#	/usr/sbin/python-updater
	#fi

	echo
	ewarn
	ewarn "If you have just upgraded from an older version of python you will need to run:"
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
	# PYTHON_DONTCOMPILE=1 breaks test_import
	unset PYTHON_DONTCOMPILE

	#skip all tests that fail during emerge but pass without emerge:
	#(See bug# 67970)
	local skip_tests="distutils global mimetools minidom mmap strptime subprocess tcl time urllib urllib2"

	for test in ${skip_tests} ; do
		mv ${S}/Lib/test/test_${test}.py ${T}
	done

	make test || die "make test failed"

	for test in ${skip_tests} ; do
		mv ${T}/test_${test}.py ${S}/Lib/test/test_${test}.py
	done

	einfo "Portage skipped the following tests which aren't able to run from emerge:"
	for test in ${skip_tests} ; do
		einfo "test_${test}.py"
	done

	einfo "If you'd like to run them, you may:"
	einfo "cd /usr/lib/python${PYVER}/test"
	einfo "and run the tests separately."
}
