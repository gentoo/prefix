# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-verve/xfce4-verve-0.3.6.ebuild,v 1.1 2009/02/09 19:52:46 angelos Exp $

inherit xfce44

xfce44

DESCRIPTION="Command line panel plugin"

KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="dbus debug"

RDEPEND=">=xfce-extra/exo-0.3.2
	dev-libs/libpcre
	dbus? ( dev-libs/dbus-glib )"
DEPEND="${RDEPEND}
	dev-util/intltool"

xfce44_goodies_panel_plugin
