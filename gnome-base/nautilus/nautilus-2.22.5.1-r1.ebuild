# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/nautilus/nautilus-2.22.5.1-r1.ebuild,v 1.9 2009/02/06 03:00:34 jer Exp $

inherit autotools eutils gnome2 virtualx

DESCRIPTION="A file manager for the GNOME desktop"
HOMEPAGE="http://www.gnome.org/projects/nautilus/"

LICENSE="GPL-2 LGPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="beagle gnome tracker"

RDEPEND=">=x11-libs/startup-notification-0.8
		 >=gnome-base/libbonobo-2.1
		 >=gnome-base/eel-2.21.90
		 >=dev-libs/glib-2.15.6
		 >=gnome-base/gnome-desktop-2.10
		 >=gnome-base/orbit-2.4
		 >=x11-libs/pango-1.1.2
		 >=x11-libs/gtk+-2.11.6
		 >=gnome-base/librsvg-2.0.1
		 >=dev-libs/libxml2-2.4.7
		 >=media-libs/libexif-0.5.12
		 >=gnome-base/gconf-2.0
		 >=gnome-base/gvfs-0.1.2
		 beagle? ( || (
			dev-libs/libbeagle
			=app-misc/beagle-0.2*
			) )
		 tracker? ( >=app-misc/tracker-0.6.4 )
		 >=gnome-base/libgnome-2.14
		 >=gnome-base/libgnomeui-2.6"
DEPEND="${RDEPEND}
		  sys-devel/gettext
		>=dev-util/pkgconfig-0.9
		>=dev-util/intltool-0.35"
PDEPEND="gnome? ( >=x11-themes/gnome-icon-theme-1.1.91 )"

DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS README THANKS TODO"

pkg_setup() {
	G2CONF="--disable-update-mimedb --disable-xmp $(use_enable beagle) $(use_enable tracker)"
}

src_unpack() {
	gnome2_src_unpack

	# bug #229719, #229723
	epatch "${FILESDIR}/${PN}-2.22.3-open-folder.patch"
	epatch "${FILESDIR}/${PN}-2.22.3-prevent-recursive-mvcp.patch"

	# "Ask what to do" by default, bug #229725
	epatch "${FILESDIR}/${PN}-2.22.5-ask-what-to-do.patch"

	# Build fix
	epatch "${FILESDIR}/${P}-fix-stat-include.patch"

	# Fix automagic exempi detection, bug #206041
	epatch "${FILESDIR}/${P}-exempi.patch"

	eautoreconf
}

src_test() {
	addwrite "/root/.gnome2_private"
	unset SESSION_MANAGER
	Xemake check || die "Test phase failed"
}

pkg_postinst() {
	gnome2_pkg_postinst

	elog "nautilus can use gstreamer to preview audio files. Just make sure"
	elog "to have the necessary plugins available to play the media type you"
	elog "want to preview"
}
