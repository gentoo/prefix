# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-mailwatch-plugin/xfce4-mailwatch-plugin-1.1.0.ebuild,v 1.1 2009/08/25 15:45:51 ssuominen Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Mail notification panel plugin"
HOMEPAGE="http://spuriousinterrupt.org/projects/mailwatch"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug ipv6 ssl"

RDEPEND=">=xfce-base/libxfce4util-4.2
	>=xfce-base/libxfcegui4-4.2
	>=xfce-base/xfce4-panel-4.3.20
	ssl? ( >=net-libs/gnutls-1.2 )"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/pkgconfig"

pkg_setup() {
	DOCS="AUTHORS ChangeLog NEWS README TODO"
	XFCONF="--disable-dependency-tracking
		$(use_enable ssl)
		$(use_enable ipv6)
		$(use_enable debug)"
	PATCHES=( "${FILESDIR}/${P}-no-ssl.patch" )
}
