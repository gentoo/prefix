# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/eel/eel-2.18.0.1.ebuild,v 1.1 2007/03/24 03:40:41 dang Exp $

EAPI="prefix"

inherit virtualx gnome2

DESCRIPTION="The Eazel Extentions Library"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE=""

RDEPEND=">=media-libs/libart_lgpl-2.3.8
	>=gnome-base/gconf-2
	>=x11-libs/gtk+-2.9.4
	>=dev-libs/glib-2.6
	>=gnome-base/libgnome-2
	>=gnome-base/libgnomeui-2.8
	>=gnome-base/gnome-vfs-2.10
	>=dev-libs/libxml2-2.4.7
	>=gnome-base/gail-0.16
	>=gnome-base/libglade-2
	>=gnome-base/gnome-desktop-2.1.4
	>=gnome-base/gnome-menus-2.14.0
	>=dev-util/desktop-file-utils-0.9"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.19"

DOCS="AUTHORS ChangeLog HACKING MAINTAINERS NEWS README THANKS TODO"

src_test() {
	if hasq userpriv $FEATURES; then
		Xmake check || die "make check failed"
	else
		einfo "Not running tests without userpriv"
	fi
}
