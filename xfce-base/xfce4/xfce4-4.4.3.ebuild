# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfce4/xfce4-4.4.3.ebuild,v 1.8 2009/08/08 23:34:50 ssuominen Exp $

HOMEPAGE="http://www.xfce.org"
DESCRIPTION="Meta package for Xfce4 desktop, merge this package to install."
SRC_URI=""

LICENSE="as-is"
SLOT="0"
IUSE=""
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"

RDEPEND=">=x11-themes/gtk-engines-xfce-2.4.3
	>=xfce-base/thunar-0.9.3
	>=xfce-base/xfce-mcs-plugins-4.4.3
	>=xfce-base/xfce4-panel-4.4.3
	>=xfce-base/xfwm4-4.4.3
	>=xfce-base/xfce-utils-4.4.3
	>=xfce-base/xfdesktop-4.4.3
	>=xfce-base/xfce4-session-4.4.3
	x11-themes/hicolor-icon-theme"

src_install() {
	dodir /etc/X11/Sessions
	echo startxfce4 > "${ED}"/etc/X11/Sessions/Xfce4
	fperms 755 /etc/X11/Sessions/Xfce4
}

pkg_postinst() {
	elog
	elog "Run Xfce4 from your favourite Display Manager by using"
	elog "XSESSION=\"Xfce4\" in /etc/rc.conf"
	elog
}
