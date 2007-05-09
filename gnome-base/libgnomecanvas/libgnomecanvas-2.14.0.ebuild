# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnomecanvas/libgnomecanvas-2.14.0.ebuild,v 1.14 2007/03/19 21:12:54 dang Exp $

EAPI="prefix"

inherit virtualx gnome2

DESCRIPTION="The Gnome 2 Canvas library"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE="doc"

RDEPEND=">=gnome-base/libglade-2
	>=x11-libs/gtk+-2.0.3
	>=x11-libs/pango-1.0.1
	>=media-libs/libart_lgpl-2.3.8"

DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"


src_test() {
	Xmake check || die "Test phase failed"
}
