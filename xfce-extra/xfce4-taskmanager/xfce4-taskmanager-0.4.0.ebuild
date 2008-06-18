# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-taskmanager/xfce4-taskmanager-0.4.0.ebuild,v 1.1 2008/06/17 22:01:53 angelos Exp $

EAPI="prefix"

inherit autotools eutils xfce44

xfce44

DESCRIPTION="Task Manager"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
HOMEPAGE="http://goodies.xfce.org/projects/applications/xfce4-taskmanager"
SRC_URI="http://goodies.xfce.org/releases/${PN}/${P}${COMPRESS}"

DOCS="AUTHORS ChangeLog NEWS README THANKS TODO"
