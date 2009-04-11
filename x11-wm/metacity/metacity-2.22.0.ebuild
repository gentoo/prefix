# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/metacity/metacity-2.22.0.ebuild,v 1.8 2008/11/13 19:15:19 ranger Exp $

inherit gnome2

DESCRIPTION="Gnome default windowmanager"
HOMEPAGE="http://blogs.gnome.org/metacity/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="xinerama"

RDEPEND=">=x11-libs/gtk+-2.10
		 >=x11-libs/pango-1.2
		 >=gnome-base/gconf-2
		 >=dev-libs/glib-2.6
		 >=x11-libs/libXcomposite-0.2
		 >=x11-libs/startup-notification-0.7
		 !x11-misc/expocity"
DEPEND="${RDEPEND}
		sys-devel/gettext
		>=dev-util/pkgconfig-0.9
		>=dev-util/intltool-0.35"

DOCS="AUTHORS ChangeLog HACKING NEWS README *.txt doc/*.txt"

pkg_setup() {
	G2CONF="$(use_enable xinerama)"
}
