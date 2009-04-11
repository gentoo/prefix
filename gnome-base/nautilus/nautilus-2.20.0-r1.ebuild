# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/nautilus/nautilus-2.20.0-r1.ebuild,v 1.12 2009/03/09 23:55:52 eva Exp $

inherit virtualx eutils gnome2 autotools

DESCRIPTION="A file manager for the GNOME desktop"
HOMEPAGE="http://www.gnome.org/projects/nautilus/"

LICENSE="GPL-2 LGPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="beagle esd gnome tracker"
# cups flac gstreamer mad ogg vorbis

RDEPEND=">=media-libs/libart_lgpl-2.3.10
	>=gnome-base/libbonobo-2.1
	>=gnome-base/eel-2.15.92
	esd? ( >=media-sound/esound-0.2.27 )
	>=dev-libs/glib-2.13
	>=gnome-base/gnome-desktop-2.9.91
	>=gnome-base/libgnome-2.14.0
	>=gnome-base/libgnomeui-2.6
	>=gnome-base/gnome-vfs-2.19.3
	>=gnome-base/orbit-2.4
	>=x11-libs/pango-1.1.2
	>=x11-libs/gtk+-2.11.6
	>=gnome-base/librsvg-2.0.1
	>=dev-libs/libxml2-2.4.7
	>=x11-libs/startup-notification-0.8
	>=media-libs/libexif-0.5.12
	>=gnome-base/gconf-2
	media-libs/audiofile
	beagle? ( =app-misc/beagle-0.2* )
	x86? ( tracker? ( >=app-misc/tracker-0.0.1 ) )
	x11-libs/libICE
	x11-libs/libSM
	x11-proto/xproto
	virtual/eject"
#	!gstreamer? ( vorbis? ( media-sound/vorbis-tools ) )
#	gstreamer? (
#		>=media-libs/gstreamer-0.8
#		>=media-libs/gst-plugins-0.8
#		>=media-plugins/gst-plugins-gnomevfs-0.8
#		mad? ( >=media-plugins/gst-plugins-mad-0.8 )
#		ogg? ( >=media-plugins/gst-plugins-ogg-0.8 )
#		vorbis? ( >=media-plugins/gst-plugins-vorbis-0.8 )
#		flac? (	>=media-plugins/gst-plugins-flac-0.8 ) )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9"
PDEPEND="gnome? ( >=x11-themes/gnome-icon-theme-1.1.91 )"

DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS README THANKS TODO"

pkg_setup() {
	G2CONF="--disable-update-mimedb $(use_enable beagle) $(use_enable tracker) $(use_enable esd esound)"
}

src_unpack() {
	gnome2_src_unpack
	epatch "${FILESDIR}/${P}-sound-preview-cleanup.patch"
	epatch "${FILESDIR}/${P}-statfs.patch"

	# Patches from unreleased 2.20.1
	epatch "${FILESDIR}/${P}-async-thumbnail-framing.patch"
	epatch "${FILESDIR}/${P}-thumbnail-flashing.patch"
	epatch "${FILESDIR}/${P}-small-font-crasher.patch"

	# Fix for autoconf 2.62, see Gnome Bug #527315
	epatch "${FILESDIR}/${PN}-2.20.0-fix_broken_configure.patch"

	eautoreconf
}

src_test() {
	addwrite "/root/.gnome2_private"
	unset SESSION_MANAGER
	Xmake check || die "Test phase failed"
}

pkg_postinst() {
	gnome2_pkg_postinst

	elog "nautilus now has three ways of previewing sound.  First, if the esd"
	elog "USE flag is given, it will attempt to play directly via esd.  If"
	elog "the esd USE flag is *not* given, it will attempt to use totem to"
	elog "play the sound.  If totem is not installed, it will attempt to use"
	elog "gstreamer 10.x to play the sound.  If gstreamer 10.x is not installed"
	elog "it will fail to preview the sound."
}
