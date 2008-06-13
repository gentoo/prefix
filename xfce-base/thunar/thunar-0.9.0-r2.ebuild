# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/thunar/thunar-0.9.0-r2.ebuild,v 1.8 2008/03/26 11:39:48 jer Exp $

EAPI="prefix 1"

inherit eutils virtualx xfce44

MY_P=${P/t/T}
S=${WORKDIR}/${MY_P}

XFCE_VERSION=4.4.2
xfce44

DESCRIPTION="File manager"
HOMEPAGE="http://thunar.xfce.org"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="doc dbus debug exif gnome hal pcre startup-notification +trash-plugin"

RDEPEND=">=dev-lang/perl-5.6
	x11-libs/libSM
	>=x11-libs/gtk+-2.6
	>=dev-libs/glib-2.6
	>=xfce-extra/exo-0.3.4
	>=x11-misc/shared-mime-info-0.20
	>=dev-util/desktop-file-utils-0.14
	>=xfce-base/libxfce4util-${XFCE_MASTER_VERSION}
	virtual/fam
	dbus? ( dev-libs/dbus-glib )
	hal? ( dev-libs/dbus-glib
		sys-apps/hal )
	>=media-libs/freetype-2
	gnome? ( gnome-base/gconf )
	exif? ( >=media-libs/libexif-0.6 )
	>=media-libs/jpeg-6b
	startup-notification? ( x11-libs/startup-notification )
	pcre? ( >=dev-libs/libpcre-6 )
	trash-plugin? ( dev-libs/dbus-glib
		>=xfce-base/xfce4-panel-${XFCE_MASTER_VERSION} )
	gnome-base/librsvg"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	doc? ( dev-util/gtk-doc )"

DOCS="AUTHORS ChangeLog HACKING FAQ THANKS TODO README NEWS"

pkg_setup() {
	XFCE_CONFIG+=" $(use_enable exif) $(use_enable gnome gnome-thumbnailers)
		$(use_enable dbus) $(use_enable pcre)"

	if use hal; then
		XFCE_CONFIG+=" --enable-dbus --with-volume-manager=hal"
	else
		XFCE_CONFIG+=" --with-volume-manager=none"
	fi

	if use trash-plugin; then
		XFCE_CONFIG+=" --enable-dbus"
	else
		XFCE_CONFIG+=" --disable-tpa-plugin"
	fi

	local fail="Re-emerge xfce-extra/exo with USE hal."
	if use hal && ! built_with_use xfce-extra/exo hal; then
		eerror "${fail}"
		die "${fail}"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-missing-audio-cds-for-volman.patch
	epatch "${FILESDIR}"/${P}-fix-defuncts.patch
}

src_test() {
	Xemake check || die "emake check failed."
}

xfce44_extra_package
