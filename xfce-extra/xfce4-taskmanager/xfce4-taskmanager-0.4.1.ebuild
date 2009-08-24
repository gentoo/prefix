# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-taskmanager/xfce4-taskmanager-0.4.1.ebuild,v 1.8 2009/08/23 16:55:38 ssuominen Exp $

inherit xfce44

xfce44

DESCRIPTION="Task Manager"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
HOMEPAGE="http://goodies.xfce.org/projects/applications/xfce4-taskmanager"
SRC_URI="http://goodies.xfce.org/releases/${PN}/${P}${COMPRESS}"
IUSE=""

RDEPEND=">=xfce-base/libxfcegui4-4.4
	>=xfce-base/libxfce4util-4.4"
DEPEND="${RDEPEND}
	dev-util/intltool"

DOCS="AUTHORS ChangeLog NEWS README THANKS TODO"
