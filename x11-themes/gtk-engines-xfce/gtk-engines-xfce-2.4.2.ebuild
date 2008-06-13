# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-xfce/gtk-engines-xfce-2.4.2.ebuild,v 1.7 2007/12/17 18:40:21 jer Exp $

EAPI="prefix"

MY_P="gtk-xfce-engine-${PV}"
S="${WORKDIR}/${MY_P}"

inherit xfce44

XFCE_VERSION=4.4.2

xfce44

DESCRIPTION="GTK+ Theme Engine"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"

RDEPEND=">=x11-libs/gtk+-2.6
	>=dev-libs/glib-2.6
	x11-libs/cairo
	x11-libs/pango"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog NEWS README"

src_unpack() {
	unpack ${A}
	sed -i -e 's:ICON.png README.html::g' "${S}"/themes/*/Makefile.in
}

xfce44_extra_package
