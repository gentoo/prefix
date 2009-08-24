# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-screenshooter/xfce4-screenshooter-1.6.0.ebuild,v 1.3 2009/08/23 21:29:52 ssuominen Exp $

EAPI=1
inherit xfce4

xfce4_gzipped
xfce4_goodies

DESCRIPTION="Xfce4 screenshooter application and panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="zimagez"

RDEPEND="xfce-base/xfce4-panel
	zimagez? ( dev-libs/xmlrpc-c
		net-misc/curl )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	XFCE_CONFIG="$(use_enable zimagez curl)
		$(use_enable zimagez xmlrpc-c)"
	DOCS="AUTHORS ChangeLog NEWS README TODO"
}
