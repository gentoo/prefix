# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.1.2.ebuild,v 1.2 2007/03/09 22:13:12 vapier Exp $

EAPI="prefix"

PATCH_VER="1.0"
UCLIBC_VER="1.0"
D_VER="0.23"

ETYPE="gcc-compiler"

# whether we should split out specs files for multiple {PIE,SSP}-by-default
# and vanilla configurations.
SPLIT_SPECS=no #${SPLIT_SPECS-true} hard disable until #106690 is fixed

inherit toolchain flag-o-matic

DESCRIPTION="The GNU Compiler Collection.  Includes C/C++, java compilers, pie+ssp extensions, Haj Ten Brugge runtime bounds checking"

LICENSE="GPL-2 LGPL-2.1"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-solaris"

RDEPEND=">=sys-libs/zlib-1.1.4
	|| ( >=sys-devel/gcc-config-1.3.12-r4 app-admin/eselect-compiler )
	virtual/libiconv
	fortran? (
		>=dev-libs/gmp-4.2.1
		>=dev-libs/mpfr-2.2.0_p10
	)
	!build? (
		gcj? (
			gtk? (
				|| ( ( x11-libs/libXt x11-libs/libX11 x11-libs/libXtst x11-proto/xproto x11-proto/xextproto ) virtual/x11 )
				>=x11-libs/gtk+-2.2
				x11-libs/pango
			)
			>=media-libs/libart_lgpl-2.1
		)
		>=sys-libs/ncurses-5.2-r2
		nls? ( sys-devel/gettext )
	)"
DEPEND="${RDEPEND}
	test? ( sys-devel/autogen dev-util/dejagnu )
	>=sys-apps/texinfo-4.2-r4
	>=sys-devel/bison-1.875
	|| ( userland_Darwin? ( >=${CATEGORY}/odcctools-20060413 )
		ppc? ( >=${CATEGORY}/binutils-2.17 )
		ppc64? ( >=${CATEGORY}/binutils-2.17 )
		>=${CATEGORY}/binutils-2.15.94 )"
PDEPEND="|| ( sys-devel/gcc-config app-admin/eselect-compiler )"
if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.3.6 )"
fi

src_unpack() {
	gcc_src_unpack

	use vanilla && return 0

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch

	# Fix cross-compiling
	epatch "${FILESDIR}"/4.1.0/gcc-4.1.0-cross-compile.patch

	[[ ${CTARGET} == *-softfloat-* ]] && epatch "${FILESDIR}"/4.0.2/gcc-4.0.2-softfloat.patch

	epatch "${FILESDIR}"/4.1.0/gcc-4.1.0-fast-math-i386-Os-workaround.patch

	[[ ${USERLAND} == "Solaris" ]] && EXTRA_ECONF="${EXTRA_ECONF} --with-gnu-ld"
}

src_compile() {
	case ${CHOST} in
		*-darwin7)
			# libintl triggers inclusion of -lc which results in multiply
			# defined symbols, so disable nls
			EXTRA_ECONF="${EXTRA_ECONF} --disable-nls"
		;;
	esac
	# Since GCC 4.1.2 some non-posix (?) /bin/sh compatible code is used, at
	# least on Solaris, so force it into our own bash
	export CONFIG_SHELL="${EPREFIX}/bin/sh"
	gcc_src_compile
}
