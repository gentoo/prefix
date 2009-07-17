# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-screenshooter/xfce4-screenshooter-1.6.0.ebuild,v 1.1 2009/07/16 04:17:14 darkside Exp $

EAPI="1"

inherit xfce4

xfce4_gzipped
xfce4_goodies

DESCRIPTION="Xfce4 screenshooter application and panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="zimagez"

DEPEND="xfce-base/xfce4-panel
        zimagez? ( dev-libs/xmlrpc-c
                net-misc/curl )"
RDEPEND="${DEPEND}"

pkg_setup() {
        XFCE_CONFIG+="$(use_enable zimagez curl) \
        $(use_enable zimagez xmlrpc-c)"
}

DOCS="AUTHORS ChangeLog NEWS README TODO"
