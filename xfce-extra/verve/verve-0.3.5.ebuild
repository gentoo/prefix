# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/verve/verve-0.3.5.ebuild,v 1.19 2007/07/01 09:35:27 welp Exp $

inherit xfce44

xfce44

DESCRIPTION="Command line panel plugin"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="dbus debug"

RDEPEND=">=xfce-extra/exo-0.3.2
	dev-libs/libpcre
	dbus? ( dev-libs/dbus-glib )"
DEPEND="${RDEPEND}
	dev-util/intltool"

xfce44_goodies_panel_plugin
