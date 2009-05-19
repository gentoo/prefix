# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-clipman/xfce4-clipman-1.0.1.ebuild,v 1.1 2009/05/18 21:00:19 angelos Exp $

EAPI=1

inherit xfce4

XFCE_VERSION=4.4
xfce4_panel_plugin

DESCRIPTION="a simple cliboard history manager for Xfce4 Panel"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=dev-libs/glib-2.14:2
	gnome-base/libglade:2.0
	>=x11-libs/gtk+-2.10:2
	>=xfce-base/libxfce4util-${XFCE_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_VERSION}
	>=xfce-base/xfce4-panel-${XFCE_VERSION}
	xfce-base/xfconf
	>=xfce-extra/exo-0.3"

DOCS="AUTHORS ChangeLog README THANKS"
