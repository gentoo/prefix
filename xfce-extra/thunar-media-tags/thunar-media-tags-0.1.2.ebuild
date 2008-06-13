# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/thunar-media-tags/thunar-media-tags-0.1.2.ebuild,v 1.19 2007/06/24 23:53:39 vapier Exp $

EAPI="prefix"

inherit xfce44

xfce44

DESCRIPTION="Thunar media tags plugin"
KEYWORDS="~amd64-linux ~x86-linux"

RDEPEND=">=media-libs/taglib-1.4"
DEPEND="${RDEPEND}"

xfce44_goodies_thunar_plugin
