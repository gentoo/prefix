# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-mount/xfce4-mount-0.5.4.ebuild,v 1.10 2007/10/24 01:32:59 angelos Exp $

EAPI="prefix"

inherit autotools xfce44

xfce44

DESCRIPTION="Mount plug-in for panel"
KEYWORDS="~amd64-linux ~x86-linux"

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i -e "/^AC_INIT/s/mount_version()/mount_version/" configure.ac
	eautoconf
}

DOCS="AUTHORS ChangeLog NEWS README THANKS TODO"

xfce44_goodies_panel_plugin
