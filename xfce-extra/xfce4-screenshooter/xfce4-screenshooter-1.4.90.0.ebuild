# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-screenshooter/xfce4-screenshooter-1.4.90.0.ebuild,v 1.1 2009/01/03 18:33:55 angelos Exp $

EAPI="prefix"

# needed because the eclass sucks
MY_P=${P}
MY_PN=${PN}

inherit eutils xfce44

xfce44
xfce44_gzipped
xfce44_goodies

DESCRIPTION="Xfce4 panel screenshooter plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

DOCS="AUTHORS ChangeLog NEWS README TODO"
