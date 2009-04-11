# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/metacity/metacity-2.20.1.ebuild,v 1.10 2009/01/31 11:46:54 eva Exp $

inherit eutils gnome2

DESCRIPTION="Gnome default windowmanager"
HOMEPAGE="http://blogs.gnome.org/metacity/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="xinerama"
# compositor needs libcm as well, not activating it for the time being

RDEPEND=">=x11-libs/gtk+-2.10
	>=x11-libs/pango-1.2
	>=gnome-base/gconf-2
	>=dev-libs/glib-2.6
	>=x11-libs/startup-notification-0.7
	!x11-misc/expocity"

# needs libcm too
#	compositor? ( >=x11-libs/libXcomposite-0.2 )

DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35"

DOCS="AUTHORS ChangeLog HACKING NEWS README *.txt doc/*.txt"

pkg_setup() {
	G2CONF="$(use_enable xinerama) \
		--disable-compositor"
}
