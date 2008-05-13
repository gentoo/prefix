# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/gnome-base/libgnomeprintui/libgnomeprintui-2.18.2.ebuild,v 1.8 2008/04/20 01:35:54 vapier Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="User interface libraries for gnome print"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="2.2"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="doc"

RDEPEND=">=x11-libs/gtk+-2.6
	>=gnome-base/libgnomeprint-2.12.1
	>=gnome-base/libgnomecanvas-1.117
	>=x11-themes/gnome-icon-theme-1.1.92"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"
