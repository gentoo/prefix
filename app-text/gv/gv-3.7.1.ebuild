# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/gv/gv-3.7.1.ebuild,v 1.3 2010/07/21 19:47:40 ssuominen Exp $

EAPI=2
inherit autotools eutils

DESCRIPTION="gv is used to view PostScript and PDF documents using Ghostscript"
HOMEPAGE="http://www.gnu.org/software/gv/"
SRC_URI="mirror://gnu/gv/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="xinerama"

DEPEND="x11-libs/libX11
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libXext
	x11-libs/libXt
	x11-libs/libXmu
	x11-libs/libXpm
	x11-libs/Xaw3d
	app-text/ghostscript-gpl
	xinerama? ( x11-libs/libXinerama )"

src_prepare() {
	epatch "${FILESDIR}"/gv-3.6.1-a0.patch

	if ! use xinerama; then
		sed -i -e 's:Xinerama:dIsAbLe&:' configure.ac || die
	fi

	sed -i \
		-e "s:-dGraphicsAlphaBits=2:\0 -dAlignToPixels=0:" \
		src/Makefile.am || die #135354

	eautoreconf
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--enable-scrollbar-code
}

src_install() {
	emake appdefaultsdir="${EPREFIX}/etc/X11/app-defaults" DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README

	doicon "${FILESDIR}"/gv_icon.xpm
	make_desktop_entry gv GhostView gv_icon "Graphics;Viewer"
}
