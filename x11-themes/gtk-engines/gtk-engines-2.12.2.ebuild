# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines/gtk-engines-2.12.2.ebuild,v 1.8 2007/12/11 10:46:13 vapier Exp $

inherit gnome2 autotools

DESCRIPTION="GTK+2 standard engines and themes"
HOMEPAGE="http://www.gtk.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="accessibility static"

RDEPEND=">=x11-libs/gtk+-2.10
	!<=x11-themes/gnome-themes-2.8.2"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.31
	>=dev-util/pkgconfig-0.9"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	G2CONF="$(use_enable static) --enable-animation"
	use accessibility || G2CONF="${G2CONF} --disable-hc"
}

src_unpack() {
	gnome2_src_unpack
	eautoreconf # need new libtool for interix
}
