# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/lua/lua-5.2.0-r1.ebuild,v 1.1 2012/03/17 21:23:08 mabi Exp $

EAPI=4

inherit eutils autotools multilib portability toolchain-funcs versionator

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

src_prepare() {
	local PATCH_PV=$(get_version_component_range 1-2)

	if [[ ${CHOST} == *-winnt* ]]; then
		epatch "${FILESDIR}"/${PN}-${PATCH_PV}-make-no-libtool.patch
	else
		epatch "${FILESDIR}"/${PN}-${PATCH_PV}-make.patch

		# Using dynamic linked lua is not recommended for performance
		# reasons. http://article.gmane.org/gmane.comp.lang.lua.general/18519
		# Mainly, this is of concern if your arch is poor with GPRs, like x86
		# Note that this only affects the interpreter binary (named lua), not the lua
		# compiler (built statically) nor the lua libraries (both shared and static
		# are installed)
		if use static ; then
			sed -i -e 's:\(-export-dynamic\):-static \1:' src/Makefile
		fi
	fi

	# fix libtool and ld usage on OSX
	if [[ ${CHOST} == *-darwin* ]] ; then
		sed -i \
			-e 's/libtool/glibtool/g' \
			-e 's/-Wl,-E//g' \
			Makefile src/Makefile
	fi

	EPATCH_SOURCE="${FILESDIR}/${PV}" EPATCH_SUFFIX="upstream.patch" epatch

	sed -i \
		-e 's:\(LUA_ROOT\s*\).*:\1"/usr/":' \
		-e "s:\(LUA_CDIR\s*LUA_ROOT \"\)lib:\1$(get_libdir):" \
		src/luaconf.h \
	|| die "failed patching luaconf.h"

	# correct lua versioning
	sed -i -e 's/\(LIB_VERSION = \)6:1:1/\17:0:2/' src/Makefile

	sed -i -e 's:\(/README\)\("\):\1.gz\2:g' doc/readme.html

	if ! use readline ; then
		sed -i -e '/#define LUA_USE_READLINE/d' src/luaconf.h
	fi

	# upstream does not use libtool, but we do (see bug #336167)
	cp "${FILESDIR}/configure.in" "${S}"
	eautoreconf
}

src_compile() {
	tc-export CC

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
	use readline && mylibs="-lreadline"

	cd src

	local legacy=""
	use deprecated && legacy="-DLUA_COMPAT_ALL"

	emake CC="${CC}" CFLAGS="-DLUA_USE_LINUX ${legacy} ${CFLAGS}" \
			SYSLDFLAGS="${LDFLAGS}" \
			RPATH="${EPREFIX}/usr/$(get_libdir)/" \
			LUA_LIBS="${mylibs}" \
			LIB_LIBS="${liblibs}" \
			V=${PV} \
			gentoo_all || die "emake failed"
}

src_install() {
	local PATCH_PV=$(get_version_component_range 1-2)

	emake INSTALL_TOP="${ED}/usr" INSTALL_LIB="${ED}/usr/$(get_libdir)" \
			V=${PV} gentoo_install \
	|| die "emake install gentoo_install failed"

	dodoc README
	dohtml doc/*.html doc/*.png doc/*.css doc/*.gif

	doman doc/lua.1 doc/luac.1

	# We want packages to find our things...
	cp "${FILESDIR}/lua.pc" "${WORKDIR}"
	sed -i \
		-e "s:^V=.*:V= ${PATCH_PV}:" \
		-e "s:^R=.*:R= ${PV}:" \
		-e "s:/,lib,:/$(get_libdir):g" \
		"${WORKDIR}/lua.pc"

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${WORKDIR}/lua.pc"
}
