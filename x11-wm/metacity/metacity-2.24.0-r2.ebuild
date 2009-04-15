# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/metacity/metacity-2.24.0-r2.ebuild,v 1.7 2009/04/12 20:48:19 bluebird Exp $

inherit eutils gnome2

DESCRIPTION="GNOME default window manager"
HOMEPAGE="http://blogs.gnome.org/metacity/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="xinerama"

RDEPEND=">=x11-libs/gtk+-2.10
	>=x11-libs/pango-1.2
	>=gnome-base/gconf-2
	>=dev-libs/glib-2.6
	>=x11-libs/startup-notification-0.7
	>=x11-libs/libXcomposite-0.2
	x11-libs/libXfixes
	x11-libs/libXrender
	x11-libs/libXdamage
	x11-libs/libXcursor
	x11-libs/libX11
	xinerama? ( x11-libs/libXinerama )
	x11-libs/libXext
	x11-libs/libXrandr
	x11-libs/libSM
	x11-libs/libICE
	!x11-misc/expocity"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35
	xinerama? ( x11-proto/xineramaproto )
	x11-proto/xextproto
	x11-proto/xproto"

DOCS="AUTHORS ChangeLog HACKING NEWS README *.txt doc/*.txt"

pkg_setup() {
	G2CONF="${G2CONF} $(use_enable xinerama)"
}

src_unpack() {
	gnome2_src_unpack
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.23.21-remove-xopen-source-posix.patch

	# Fix compilation on *bsd, bug #256224
	epatch "${FILESDIR}/${P}-fbsd.patch"

	# Fix crash on login, upstream bug #553980
	epatch "${FILESDIR}/${P}-crash-login.patch"

	# Fix a leak misused gslist function, bug #258301
	epatch "${FILESDIR}/${P}-gslist-leak.patch"

	# Fix a string leak, bug #258302
	epatch "${FILESDIR}/${P}-string-leak.patch"
}
