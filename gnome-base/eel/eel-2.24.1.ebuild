# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/eel/eel-2.24.1.ebuild,v 1.10 2009/04/27 13:21:11 jer Exp $

inherit virtualx gnome2

DESCRIPTION="The Eazel Extentions Library"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="test"

# FIXME: needs a running at-spi-registryd (setup a virtual session ?)
RESTRICT="test"

RDEPEND=">=dev-libs/glib-2.15
		 >=x11-libs/gtk+-2.13
		 >=gnome-base/gconf-2.0
		 >=dev-libs/libxml2-2.4.7
		 >=gnome-base/libglade-2.0
		 >=gnome-base/gnome-desktop-2.23.3
		 >=x11-libs/startup-notification-0.8

		 >=gnome-base/libgnome-2.23.0
		 >=gnome-base/libgnomeui-2.8"
DEPEND="${RDEPEND}
		  sys-devel/gettext
		>=dev-util/intltool-0.35
		>=dev-util/pkgconfig-0.19
		test? ( gnome-extra/libgail-gnome )"

DOCS="AUTHORS ChangeLog HACKING MAINTAINERS NEWS README THANKS TODO"

src_test() {
	if hasq userpriv $FEATURES; then
		einfo "Not running tests without userpriv"
	else
		addwrite "/root/.gnome2"
		Xmake check || die "make check failed"
	fi
}
