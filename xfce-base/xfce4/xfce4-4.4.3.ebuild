# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfce4/xfce4-4.4.3.ebuild,v 1.7 2008/12/15 05:04:19 jer Exp $

HOMEPAGE="http://www.xfce.org"
DESCRIPTION="Meta package for Xfce4 desktop, merge this package to install."
SRC_URI=""

LICENSE="as-is"
SLOT="0"
IUSE="alsa cups minimal oss xscreensaver"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"

RDEPEND=">=x11-themes/gtk-engines-xfce-2.4.3
	>=xfce-base/thunar-0.9.3
	>=xfce-base/xfce-mcs-plugins-4.4.3
	>=xfce-base/xfce4-panel-4.4.3
	>=xfce-base/xfwm4-4.4.3
	>=xfce-base/xfce-utils-4.4.3
	>=xfce-base/xfdesktop-4.4.3
	>=xfce-base/xfce4-session-4.4.3
	alsa? ( >=xfce-extra/xfce4-mixer-4.4.3 )
	oss? ( >=xfce-extra/xfce4-mixer-4.4.3 )
	cups? ( >=net-print/xfprint-4.4.3 )
	!minimal? ( >=app-office/orage-4.4.3
		>=app-editors/mousepad-0.2.14
		>=x11-themes/xfce4-icon-theme-4.4.3
		>=x11-themes/xfwm4-themes-4.4.3
		>=x11-terms/terminal-0.2.8.3
		>=xfce-extra/xfce4-appfinder-4.4.3 )
	minimal? ( x11-themes/hicolor-icon-theme )
	xscreensaver? ( || ( x11-misc/xscreensaver
		gnome-extra/gnome-screensaver ) )"

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
