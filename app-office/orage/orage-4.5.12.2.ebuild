# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/orage/orage-4.5.12.2.ebuild,v 1.1 2008/06/22 23:21:36 drac Exp $

EAPI="prefix"

inherit gnome2-utils

DESCRIPTION="Calendar suite for Xfce4"
HOMEPAGE="http://www.kolumbus.fi/~w408237/orage"
SRC_URI="http://www.kolumbus.fi/~w408237/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
# This package is waiting for alpha/beta/rc of Xfce 4.6, so please
# don't mark it stable.
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="dbus debug libnotify"

RDEPEND=">=dev-libs/glib-2.6
	>=x11-libs/gtk+-2.6
	>=xfce-base/libxfce4mcs-4.4
	>=xfce-base/libxfce4util-4.4
	>=xfce-base/libxfcegui4-4.4
	>=xfce-base/xfce4-panel-4.4
	dbus? ( dev-libs/dbus-glib )
	libnotify? ( x11-libs/libnotify )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	sys-devel/gettext"

S=${WORKDIR}/${P}-svn

src_compile() {
	econf $(use_enable dbus) \
		$(use_enable debug) \
		$(use_enable libnotify)
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	gnome2_icon_cache_update
	elog "There is no migration support from 4.4 to 4.5 so you need to copy Orage files by hand."
}

pkg_postrm() {
	gnome2_icon_cache_update
}
# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/orage/orage-4.5.12.2.ebuild,v 1.1 2008/06/22 23:21:36 drac Exp $

EAPI="prefix"

inherit xfce44 autotools

XFCE_VERSION="4.4.1"
xfce44

DESCRIPTION="Calendar"
HOMEPAGE="http://www.kolumbus.fi/~w408237/orage"
SRC_URI="http://www.kolumbus.fi/~w408237/${PN}/${P}.tar.bz2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="dbus debug libnotify"

S="${WORKDIR}"/${P}-svn

RDEPEND=">=dev-libs/glib-2.6
	>=x11-libs/gtk+-2.6
	>=xfce-base/libxfce4mcs-${XFCE_MASTER_VERSION}
	>=xfce-base/libxfce4util-${XFCE_MASTER_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_MASTER_VERSION}
	>=xfce-base/xfce4-panel-${XFCE_MASTER_VERSION}
	dbus? ( dev-libs/dbus-glib )
	libnotify? ( x11-libs/libnotify )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	x86-interix? ( xfce-extra/xfce4-dev-tools )
	!xfce-extra/xfcalendar"

DOCS="AUTHORS ChangeLog NEWS README"

XFCE_CONFIG="${XFCE_CONFIG} $(use_enable dbus) $(use_enable libnotify)"

src_unpack() {
	unpack ${A}
	cd "${S}"

	use x86-interix && NOCONFIGURE=yes xdt-autogen # need new libtool for interix
}

pkg_postinst() {
	xfce44_pkg_postinst
	elog
	elog "There is no migration support from 4.4 to 4.5 so you need to copy	Orage files manually."
	elog
}
