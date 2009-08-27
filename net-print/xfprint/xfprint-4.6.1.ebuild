# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/xfprint/xfprint-4.6.1.ebuild,v 1.11 2009/08/25 18:05:37 ssuominen Exp $

EAUTORECONF=yes
EAPI=2
inherit xfconf

DESCRIPTION="Frontend for printing, management and job queue."
HOMEPAGE="http://www.xfce.org/projects/xfprint"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="cups debug"

RDEPEND="app-text/a2ps
	>=x11-libs/gtk+-2.10:2
	>=xfce-base/libxfce4util-4.6
	>=xfce-base/libxfcegui4-4.6
	>=xfce-base/xfconf-4.6
	cups? ( net-print/cups )
	!cups? ( net-print/lprng )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

pkg_setup() {
	XFCONF="--disable-dependency-tracking
		$(use_enable cups)
		--enable-bsdlpr
		$(use_enable debug)"
	DOCS="AUTHORS ChangeLog NEWS README TODO"
}

src_prepare() {
	sed -i -e "/24x24/d" "${S}"/icons/Makefile.am || die "sed failed"
	xfconf_src_prepare
}
