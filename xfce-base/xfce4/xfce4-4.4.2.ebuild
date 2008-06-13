# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfce4/xfce4-4.4.2.ebuild,v 1.10 2008/03/20 21:56:32 drac Exp $

EAPI="prefix"

inherit xfce44

XFCE_VERSION=4.4.2
xfce44

HOMEPAGE="http://www.xfce.org"
DESCRIPTION="Meta package for Xfce4 desktop, merge this package to install."
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="alsa cups minimal oss xscreensaver"

RDEPEND=">=x11-themes/gtk-engines-xfce-2.4.2
	>=xfce-base/thunar-0.8.0
	>=xfce-base/xfce-mcs-plugins-${XFCE_MASTER_VERSION}
	>=xfce-base/xfce4-panel-${XFCE_MASTER_VERSION}
	>=xfce-base/xfwm4-${XFCE_MASTER_VERSION}
	>=xfce-base/xfce-utils-${XFCE_MASTER_VERSION}
	>=xfce-base/xfdesktop-${XFCE_MASTER_VERSION}
	>=xfce-base/xfce4-session-${XFCE_MASTER_VERSION}
	>=xfce-extra/xfce4-icon-theme-${XFCE_MASTER_VERSION}
	alsa? ( >=xfce-extra/xfce4-mixer-${XFCE_MASTER_VERSION} )
	oss? ( >=xfce-extra/xfce4-mixer-${XFCE_MASTER_VERSION} )
	cups? ( >=xfce-base/xfprint-${XFCE_MASTER_VERSION} )
	!minimal? ( >=xfce-base/orage-${XFCE_MASTER_VERSION}
		>=xfce-extra/mousepad-0.2.13
		>=xfce-extra/xfwm4-themes-${XFCE_MASTER_VERSION}
		>=xfce-extra/terminal-0.2.8
		>=xfce-extra/xfce4-appfinder-${XFCE_MASTER_VERSION} )
	xscreensaver? ( || ( >=x11-misc/xscreensaver-5.03
		gnome-extra/gnome-screensaver ) )"
DEPEND="${RDEPEND}"

# hack to avoid exporting function from eclass.
# we need eclass to get _MASTER_VERSION.
src_compile() {
	echo
}

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
