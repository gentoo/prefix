# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/lua/lua-5.1.4-r4.ebuild,v 1.12 2012/09/05 09:28:49 jlec Exp $

EAPI=1

inherit eutils multilib portability toolchain-funcs versionator

DESCRIPTION="A powerful light-weight programming language designed for extending applications"
HOMEPAGE="http://www.lua.org/"
SRC_URI="http://www.lua.org/ftp/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="+deprecated emacs readline static"

RDEPEND="readline? ( sys-libs/readline )"
DEPEND="${RDEPEND}
	sys-devel/libtool"
PDEPEND="emacs? ( app-emacs/lua-mode )"

src_unpack() {
	local PATCH_PV=$(get_version_component_range 1-2)
	unpack ${A}
	cd "${S}"

	if [[ ${CHOST} == *-winnt* ]]; then
		epatch "${FILESDIR}"/${PN}-${PATCH_PV}-make-no-libtool.patch
	else
		epatch "${FILESDIR}"/${PN}-${PATCH_PV}-make-r1.patch

		# Using dynamic linked lua is not recommended upstream for performance
		# reasons. http://article.gmane.org/gmane.comp.lang.lua.general/18519
		# Mainly, this is of concern if your arch is poor with GPRs, like x86
		# Not that this only affects the interpreter binary (named lua), not the lua
		# compiler (built statically) nor the lua libraries (both shared and static
		# are installed)
		if use static ; then
			epatch "${FILESDIR}"/${PN}-${PATCH_PV}-make_static-r1.patch
		fi
	fi

	epatch "${FILESDIR}"/${PN}-${PATCH_PV}-module_paths.patch

	# fix libtool and ld usage on OSX
	if [[ ${CHOST} == *-darwin* ]] ; then
		sed -i \
			-e 's/libtool/glibtool/g' \
			-e 's/-Wl,-E//g' \
			Makefile src/Makefile
	fi

	EPATCH_SOURCE="${FILESDIR}/${PV}" EPATCH_SUFFIX="upstream.patch" epatch

	# correct lua versioning
	sed -i -e 's/\(LIB_VERSION = \)6:1:1/\16:4:1/' src/Makefile

	sed -i -e 's:\(/README\)\("\):\1.gz\2:g' doc/readme.html

	if ! use deprecated ; then
		epatch "${FILESDIR}"/${P}-deprecated.patch
		epatch "${FILESDIR}"/${P}-test.patch
	fi

	if ! use readline ; then
		epatch "${FILESDIR}"/${PN}-${PATCH_PV}-readline.patch
	fi

	# We want packages to find our things...
	sed -i \
		-e "s:/usr/local:${EPREFIX}/usr:" \
		-e "s:/\<lib\>:/$(get_libdir):g" \
		etc/lua.pc
}

src_compile() {
	tc-export CC
	myflags=
	# what to link to liblua
	liblibs="-lm"
	if [[ $CHOST == *-darwin* ]]; then
		mycflags="${mycflags} -DLUA_USE_MACOSX"
	elif [[ ${CHOST} == *-winnt* ]]; then
		: # nothing for now...
	elif [[ ${CHOST} == *-interix* ]]; then
		: # nothing here too...
	else # building for standard linux (and bsd too)
		mycflags="${mycflags} -DLUA_USE_LINUX"
	fi
	liblibs="${liblibs} $(dlopen_lib)"

	# what to link to the executables
	mylibs=
	if use readline; then
		mylibs="-lreadline"
	fi

	cd src
	emake CC="${CC}" CFLAGS="${mycflags} ${CFLAGS}" \
			RPATH="${EROOT}/usr/$(get_libdir)/" \
			LUA_LIBS="${mylibs}" \
			LIB_LIBS="${liblibs}" \
			V=${PV} \
			gentoo_all || die "emake failed"

	mv lua_test ../test/lua.static
}

src_install() {
	emake INSTALL_TOP="${ED}/usr/" INSTALL_LIB="${ED}/usr/$(get_libdir)/" \
			V=${PV} gentoo_install \
	|| die "emake install gentoo_install failed"

	dodoc HISTORY README
	dohtml doc/*.html doc/*.gif

	doicon etc/lua.ico
	insinto /usr/$(get_libdir)/pkgconfig
	doins etc/lua.pc

	doman doc/lua.1 doc/luac.1
}

src_test() {
	local positive="bisect cf echo env factorial fib fibfor hello printf sieve
	sort trace-calls trace-globals"
	local negative="readonly"
	local test

	cd "${S}"
	for test in ${positive}; do
		test/lua.static test/${test}.lua || die "test $test failed"
	done

	for test in ${negative}; do
		test/lua.static test/${test}.lua && die "test $test failed"
	done
}
