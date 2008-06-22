# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/gv/gv-3.6.4.ebuild,v 1.1 2008/06/21 07:29:23 drac Exp $

EAPI="prefix"

inherit autotools eutils

DESCRIPTION="gv is used to view PostScript and PDF documents using Ghostscript"
HOMEPAGE="http://www.gnu.org/software/gv/"
SRC_URI="mirror://gnu/gv/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXmu
	x11-libs/libXpm
	x11-libs/Xaw3d
	virtual/ghostscript
	x11-libs/libXt"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/gv-3.6.1-a0.patch
	# Make font render nicely even with gs-8, bug 135354
	sed -i \
		-e "s:-dGraphicsAlphaBits=2:\0 -dAlignToPixels=0:" \
		src/{gv_{class,user,system}.ad,Makefile.am} || die "sed failed."

	eautoreconf
}

src_compile() {
	econf --disable-dependency-tracking \
		--enable-scrollbar-code || die "econf failed."
	emake || die "emake failed."
}

src_install() {
	emake appdefaultsdir="${EPREFIX}/etc/X11/app-defaults" DESTDIR="${D}" install || die "make install failed."
	doicon src/gv_icon.xbm
	make_desktop_entry gv "GhostView" /usr/share/pixmaps/gv_icon.xbm "Graphics;Viewer;"
	dodoc AUTHORS ChangeLog README
}
