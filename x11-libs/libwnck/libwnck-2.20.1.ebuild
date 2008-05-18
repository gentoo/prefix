# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libwnck/libwnck-2.20.1.ebuild,v 1.8 2007/12/11 22:47:50 vapier Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="A window navigation construction kit"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="doc"

RDEPEND=">=x11-libs/gtk+-2.11.3
	>=dev-libs/glib-2.13.0
	>=x11-libs/startup-notification-0.4
	x11-libs/libX11
	x11-libs/libXres
	x11-libs/libXext"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README"
