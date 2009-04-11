# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnomeprintui/libgnomeprintui-2.18.4.ebuild,v 1.1 2009/03/08 01:26:41 eva Exp $

GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="User interface libraries for gnome print"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="2.2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
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

G2CONF="${G2CONF} --disable-static"
