# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfce-utils/xfce-utils-4.4.3.ebuild,v 1.7 2009/05/01 04:28:50 darkside Exp $

EAPI=1

inherit eutils xfce44

XFCE_VERSION=4.4.3

xfce44
xfce44_core_package

DESCRIPTION="Collection of utils"
HOMEPAGE="http://www.xfce.org/projects/xfce-utils"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="dbus debug +lock"

RDEPEND="x11-apps/xrdb
	x11-libs/libX11
	>=dev-libs/glib-2.6:2
	>=x11-libs/gtk+-2.6:2
	>=xfce-base/libxfcegui4-${XFCE_MASTER_VERSION}
	>=xfce-base/libxfce4mcs-${XFCE_MASTER_VERSION}
	>=xfce-base/xfce-mcs-manager-${XFCE_MASTER_VERSION}
	dbus? ( dev-libs/dbus-glib )
	lock? ( || ( x11-misc/xscreensaver
		gnome-extra/gnome-screensaver
		x11-misc/xlockmore ) )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	XFCE_CONFIG="${XFCE_CONFIG} $(use_enable dbus) \
		--with-vendor-info=Gentoo"
	# Prefix cannot do --enable-gdm
	use prefix || XFCE_CONFIG="${XFCE_CONFIG} --enable-gdm"
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-4.4.2-nolisten-tcp.patch
}

src_install() {
	xfce44_src_install
	insinto /usr/share/xfce4
	doins "${FILESDIR}"/Gentoo
}
