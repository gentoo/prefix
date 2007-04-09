# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/transfig/transfig-3.2.4-r2.ebuild,v 1.17 2007/04/02 15:08:08 pva Exp $

EAPI="prefix"

IUSE=""

inherit toolchain-funcs eutils

MY_P=${PN}.${PV}
S=${WORKDIR}/${MY_P}
SHAPE_P=shape-patch.${PV}-shape-1.1

DESCRIPTION="A set of tools for creating TeX documents with graphics which can be printed in a wide variety of environments"
SRC_URI="http://www.xfig.org/xfigdist/${MY_P}.tar.gz
	http://www.ctan.org/tex-archive/graphics/transfig-shapepatch/${SHAPE_P}.tar.gz"
HOMEPAGE="http://www.xfig.org"

SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"

RDEPEND="|| ( x11-libs/libXpm virtual/x11 )
	>=media-libs/jpeg-6
	media-libs/libpng"
DEPEND="${RDEPEND}
	|| ( ( x11-misc/imake
			app-text/rman
		)
		virtual/x11
	)"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}.patch
	epatch ../${SHAPE_P}/${PN}.${SHAPE_P#*.}.patch	# bug #20877

	# Apply gcc-3.3 patch for GCC 3.3 and above -- bug #110948
	if [ "$(gcc-major-version)$(gcc-minor-version)" -ge "33" ];
	then
		epatch  ${FILESDIR}/${P}-gcc-3.3.patch
	fi
}

src_compile() {
	xmkmf || die "xmkmf failed"
	make Makefiles || die "make Makefiles failed"

	emake \
		CC="$(tc-getCC)" LOCAL_LDFLAGS="${LDFLAGS}" CDEBUGFLAGS="${CFLAGS}" \
		BINDIR="${EPREFIX}"/usr/bin LIBDIR="${EPREFIX}"/usr/$(get_libdir) || die "emake failed"
}

src_install() {
	make \
		DESTDIR="${D}" \
		BINDIR="${EPREFIX}"/usr/bin \
		LIBDIR="${EPREFIX}"/usr/$(get_libdir) \
		install || die

	#Install docs
	dodoc README CHANGES LATEX.AND.XFIG NOTES
	dodoc ../${SHAPE_P}/shapepatch.README
	doman doc/fig2dev.1
	doman doc/fig2ps2tex.1
	doman doc/pic2tpic.1
}
