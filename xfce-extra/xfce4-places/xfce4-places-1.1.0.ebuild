# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-places/xfce4-places-1.1.0.ebuild,v 1.1 2008/06/09 14:46:15 angelos Exp $

EAPI="prefix"

inherit xfce44

xfce44

DESCRIPTION="Places menu plug-in for panel, like GNOME's"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=xfce-base/thunar-${THUNAR_MASTER_VERSION}"
DEPEND="${RDEPEND}
	dev-util/intltool"

DOCS="AUTHORS ChangeLog NEWS README TODO"

xfce44_goodies_panel_plugin
