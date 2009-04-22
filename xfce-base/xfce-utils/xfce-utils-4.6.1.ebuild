# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfce-utils/xfce-utils-4.6.1.ebuild,v 1.1 2009/04/21 04:25:16 darkside Exp $

EAPI="1"

inherit xfce4

xfce4_core

DESCRIPTION="Collection of utils"
HOMEPAGE="http://www.xfce.org/projects/xfce-utils/"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="dbus debug +lock"

RDEPEND="x11-apps/xrdb
	x11-libs/libX11
	>=dev-libs/glib-2.6:2
	>=x11-libs/gtk+-2.10:2
	>=xfce-base/libxfce4util-${XFCE_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_VERSION}
	>=xfce-base/xfconf-${XFCE_VERSION}
	dbus? ( dev-libs/dbus-glib )
	lock? ( || ( x11-misc/xscreensaver
		gnome-extra/gnome-screensaver
		x11-misc/xlockmore ) )"
DEPEND="${RDEPEND}
	dev-util/intltool"

pkg_setup() {
	XFCE_CONFIG+=" $(use_enable dbus) --with-vendor-info=Gentoo"
	# Prefix cannot do --enable-gdm
	use prefix || XFCE_CONFIG="${XFCE_CONFIG} --enable-gdm"
	# and upstream insists on placing xfce.desktop in /usr
	use prefix && XFCE_CONFIG="${XFCE_CONFIG} --with-xsession-prefix=${EPREFIX}/usr"
}

src_install() {
	xfce4_src_install

	insinto /usr/share/xfce4
	doins "${FILESDIR}/Gentoo"

	dodir /etc/X11/Sessions
	echo startxfce4 > "${ED}/etc/X11/Sessions/Xfce4"
	fperms 755 /etc/X11/Sessions/Xfce4
}

pkg_postinst() {
	elog
	elog "Run Xfce4 from your favourite Display Manager by using"
	elog "XSESSION=\"Xfce4\" in /etc/rc.conf"
	elog
}

DOCS="AUTHORS ChangeLog NEWS README TODO"
