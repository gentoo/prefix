# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-screenshooter/xfce4-screenshooter-1.5.1.ebuild,v 1.1 2009/03/10 14:26:36 angelos Exp $

inherit xfce4

xfce4_gzipped
xfce4_goodies

DESCRIPTION="Xfce4 screenshooter application and panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="xfce-base/xfce4-panel"
RDEPEND="${DEPEND}"

DOCS="AUTHORS ChangeLog NEWS README TODO"
