# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfce4/xfce4-4.6.0.ebuild,v 1.2 2009/03/16 08:04:10 angelos Exp $

XFCE_VERSION=${PV}

HOMEPAGE="http://www.xfce.org"
DESCRIPTION="Meta package for Xfce4 desktop, merge this package to install."
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="alsa cups minimal oss xscreensaver"

RDEPEND=">=x11-themes/gtk-engines-xfce-2.6
	>=xfce-base/thunar-0.9.92
	>=xfce-base/xfce4-panel-${XFCE_VERSION}
	>=xfce-base/xfwm4-${XFCE_VERSION}
	>=xfce-base/xfce-utils-${XFCE_VERSION}
	>=xfce-base/xfdesktop-${XFCE_VERSION}
	>=xfce-base/xfce4-session-${XFCE_VERSION}
	!alpha? ( >=xfce-base/xfce4-settings-${XFCE_VERSION} )
	alsa? ( >=xfce-extra/xfce4-mixer-${XFCE_VERSION} )
	oss? ( >=xfce-extra/xfce4-mixer-${XFCE_VERSION} )
	cups? ( >=net-print/xfprint-${XFCE_VERSION} )
	!minimal? ( >=app-office/orage-${XFCE_VERSION}
		app-editors/mousepad
		x11-terms/terminal
		x11-themes/xfce4-icon-theme
		>=x11-themes/xfwm4-themes-${XFCE_VERSION}
		>=xfce-extra/xfce4-appfinder-${XFCE_VERSION} )
	minimal? ( x11-themes/hicolor-icon-theme )
	xscreensaver? ( || ( >=x11-misc/xscreensaver-5.03
		gnome-extra/gnome-screensaver ) )"
