# Copyright 2008-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-settings-daemon/gnome-settings-daemon-2.24.1-r1.ebuild,v 1.6 2009/03/18 15:03:25 armin76 Exp $

inherit autotools eutils gnome2

DESCRIPTION="Gnome Settings Daemon"
HOMEPAGE="http://www.gnome.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="alsa debug esd gstreamer libnotify pulseaudio"

RDEPEND=">=dev-libs/dbus-glib-0.74
	>=dev-libs/glib-2.18.0
	>=x11-libs/gtk+-2.10
	>=gnome-base/gconf-2.6.1
	>=gnome-base/libgnomekbd-2.21.4

	>=gnome-base/libglade-2
	>=gnome-base/libgnome-2
	>=gnome-base/libgnomeui-2
	>=gnome-base/gnome-desktop-2.23.90

	libnotify? ( >=x11-libs/libnotify-0.4.3 )

	x11-libs/libX11
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXext
	x11-libs/libXxf86misc
	>=x11-libs/libxklavier-3.3
	media-libs/fontconfig

	esd? ( >=media-sound/esound-0.2.28 )
	gstreamer? (
		>=media-libs/gstreamer-0.10.1.2
		>=media-libs/gst-plugins-base-0.10.1.2 )
	!gstreamer? (
		alsa? ( >=media-libs/alsa-lib-0.99 ) )"
# In configure: gstreamer wins over alsa

DEPEND="${RDEPEND}
	!<gnome-base/gnome-control-center-2.22
	sys-devel/gettext
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.19
	x11-proto/inputproto
	x11-proto/xproto"

# FIXME: pulseaudio is used to detect if system should build
# old sound preference capplet (some braindead logic in there)
PDEPEND="pulseaudio? ( >=media-sound/pulseaudio-0.9.9 )"

# README is empty
DOCS="AUTHORS NEWS ChangeLog MAINTAINERS"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable alsa)
		$(use_enable debug)
		$(use_enable esd)
		$(use_enable gstreamer)
		$(use_enable libnotify)
		$(use_enable !pulseaudio legacy-sound-pref)"
	# We use legacy-sound-pref instead of pulse because
	# there is no gain in adding a build time dep on pulseaudio

	if use esd && use pulseaudio; then
		ewarn "You selected conflicting USE flags. Please note that USE=\"esd\""
		ewarn "has no effect when USE=\"pulseaudio\" is selected."
	fi
}

src_unpack() {
	gnome2_src_unpack

	# Fix libnotify & pulseaudio automagic dependencies
	epatch "${FILESDIR}/${PN}-2.24.0-automagic.patch"

	# Fix server-side XInput detection (Gnome bug #562977)
	epatch "${FILESDIR}/${PN}-2.24.1-check-for-server-side-XInput.patch"

	eautoreconf
}
