# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/thunar/thunar-1.0.0.ebuild,v 1.1 2009/03/10 13:49:26 angelos Exp $

EAPI=2

MY_PN=${PN/t/T}
inherit virtualx xfce4

XFCE_VERSION=4.6.0

xfce4_core

DESCRIPTION="File manager"
HOMEPAGE="http://thunar.xfce.org"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="dbus debug doc exif gnome hal pcre startup-notification +trash-plugin"

RDEPEND=">=dev-lang/perl-5.6
	>=dev-libs/glib-2.6:2
	>=dev-util/desktop-file-utils-0.14
	>=media-libs/freetype-2
	>=media-libs/jpeg-6b
	>=media-libs/libpng-1.2.0
	virtual/fam
	>=x11-libs/gtk+-2.6:2
	x11-libs/libSM
	>=x11-misc/shared-mime-info-0.20
	>=xfce-extra/exo-0.3.92[hal?]
	>=xfce-base/libxfce4util-${XFCE_VERSION}
	dbus? ( dev-libs/dbus-glib )
	exif? ( >=media-libs/libexif-0.6 )
	hal? ( dev-libs/dbus-glib
		sys-apps/hal )
	gnome? ( gnome-base/gconf )
	pcre? ( >=dev-libs/libpcre-6 )
	startup-notification? ( x11-libs/startup-notification )
	trash-plugin? ( dev-libs/dbus-glib
		>=xfce-base/xfce4-panel-${XFCE_VERSION} )"
DEPEND="${RDEPEND}
	dev-util/intltool
	doc? ( dev-util/gtk-doc )"

pkg_setup() {
	XFCE_CONFIG+="$(use_enable dbus) $(use_enable doc gtk-doc)
	$(use_enable exif) $(use_enable gnome gnome-thumbnailers)
	$(use_enable pcre)"

	if use hal && ! use dbus; then
		ewarn "USE hal detected, enabling dbus."
	fi

	if use hal; then
		XFCE_CONFIG+=" --enable-dbus --with-volume-manager=hal"
	else
		XFCE_CONFIG+=" --with-volume-manager=none"
	fi

	if use trash-plugin && ! use dbus; then
		XFCE_CONFIG+=" --enable-dbus"
		ewarn "USE trash-plugin detected, enabling dbus."
	fi

	use trash-plugin || XFCE_CONFIG+=" --disable-tpa-plugin"
}

src_test() {
	Xemake check || die "emake check failed"
}

DOCS="AUTHORS ChangeLog FAQ HACKING NEWS README THANKS TODO"
