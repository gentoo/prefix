# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/lxde-base/lxpanel/lxpanel-0.4.1.ebuild,v 1.2 2009/05/24 23:03:45 yngwin Exp $

EAPI="2"
inherit eutils autotools

DESCRIPTION="Lightweight X11 desktop panel for LXDE"
HOMEPAGE="http://lxde.sf.net/"
SRC_URI="mirror://sourceforge/lxde/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
SLOT="0"
IUSE="+X +alsa wifi"
RESTRICT="test"  # bug 249598

RDEPEND="x11-libs/gtk+:2
	x11-libs/libXmu
	x11-libs/libXpm
	lxde-base/lxmenu-data
	lxde-base/menu-cache
	alsa? ( media-libs/alsa-lib )
	wifi? ( net-wireless/wireless-tools )
	X? ( x11-libs/libX11 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-sandbox.patch
	eautoreconf
}

src_configure() {
	local plugins="all"

	[[ ${CHOST} == *-interix* ]] && plugins="deskno,kbled,xkb"

	econf $(use_enable alsa) \
		$(use_enable wifi libiw) \
		$(use_with X x) \
		--with-plugins=${plugins}
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog README
}
