# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-screenshooter/xfce4-screenshooter-1.6.0.ebuild,v 1.10 2009/09/05 15:33:35 ranger Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Xfce4 screenshooter application and panel plugin"
HOMEPAGE="http://goodies.xfce.org/projects/applications/xfce4-screenshooter"
SRC_URI="http://goodies.xfce.org/releases/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="debug zimagez"

RDEPEND=">=x11-libs/gtk+-2.12:2
	>=dev-libs/glib-2.16:2
	>=xfce-base/xfce4-panel-4.4
	>=xfce-base/libxfce4util-4.4
	>=xfce-base/libxfcegui4-4.4
	zimagez? ( dev-libs/xmlrpc-c net-misc/curl )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
	DOCS="AUTHORS ChangeLog NEWS README TODO"
}
