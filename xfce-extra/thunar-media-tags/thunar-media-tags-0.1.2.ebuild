# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/thunar-media-tags/thunar-media-tags-0.1.2.ebuild,v 1.20 2008/09/24 10:08:22 aballier Exp $

inherit xfce44

xfce44

DESCRIPTION="Thunar media tags plugin"
KEYWORDS="~amd64-linux ~x86-linux"

RDEPEND=">=media-libs/taglib-1.4"
DEPEND="${RDEPEND}"

xfce44_goodies_thunar_plugin
