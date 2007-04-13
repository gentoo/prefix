# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/gv/gv-3.6.2-r1.ebuild,v 1.12 2007/04/07 17:30:26 genstef Exp $

EAPI="prefix"

inherit eutils

DPF="gv_3.6.2-3"
DESCRIPTION="gv is used to view PostScript and PDF documents using Ghostscript"
HOMEPAGE="http://www.gnu.org/software/gv/"
SRC_URI="mirror://gnu/gv/${P}.tar.gz
	mirror://debian/pool/main/g/gv/${DPF}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

RDEPEND="x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXmu
	x11-libs/libXpm
	x11-libs/libXt
	x11-libs/Xaw3d
	virtual/ghostscript"

DEPEND="${RDEPEND}
	|| (
		x11-libs/libXt
		virtual/x11
	)"
src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/gv-3.6.1-setenv.patch
	epatch "${FILESDIR}"/gv-3.6.1-a0.patch
	epatch "${FILESDIR}"/gv-3.6.1-fixedmedia.patch
	epatch "${FILESDIR}"/gv-update.patch
	epatch "${FILESDIR}"/gv-30_config.patch
	# apply debian patches
	epatch "${WORKDIR}"/${DPF}.diff
	epatch ${P}/debian/patches/{*-*,*_*}
	# Make font render nicely even with gs-8, bug 135354
	sed -i -e "s:-dGraphicsAlphaBits=2:\0 -dAlignToPixels=0:" \
		src/{gv_{class,user,system}.ad,Makefile.{am,in}}
}

src_compile() {
	econf --enable-scrollbar-code || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make appdefaultsdir="${EPREFIX}/etc/X11/app-defaults" DESTDIR="${D}" install || die "make install failed"
	doicon src/gv_icon.xbm
	make_desktop_entry gv "GhostView" /usr/share/pixmaps/gv_icon.xbm "Application;Graphics;Viewer;"
	dodoc AUTHORS ChangeLog INSTALL README TODO
}
