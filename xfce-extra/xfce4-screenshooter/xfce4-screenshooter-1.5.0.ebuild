# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-screenshooter/xfce4-screenshooter-1.5.0.ebuild,v 1.2 2009/02/19 07:59:09 angelos Exp $

EAPI="prefix"

# needed because the eclass sucks
MY_P=${P}
MY_PN=${PN}

inherit eutils xfce44

xfce44
xfce44_gzipped
xfce44_goodies

DESCRIPTION="Xfce4 screenshooter application and panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="xfce-base/xfce4-panel"
RDEPEND="${DEPEND}"

DOCS="AUTHORS ChangeLog NEWS README TODO"
