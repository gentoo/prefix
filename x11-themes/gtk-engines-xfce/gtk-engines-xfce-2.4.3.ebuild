# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-xfce/gtk-engines-xfce-2.4.3.ebuild,v 1.6 2008/12/15 04:52:18 jer Exp $

EAPI=1
MY_P="gtk-xfce-engine-${PV}"

inherit xfce44

XFCE_VERSION=4.4.3

xfce44
xfce44_extra_package

DESCRIPTION="GTK+ Theme Engine"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=dev-libs/glib-2.6:2
	x11-libs/cairo
	>=x11-libs/gtk+-2.6:2
	x11-libs/pango"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	sed -i -e 's:ICON.png README.html::g' "${S}"/themes/*/Makefile.in
}

DOCS="AUTHORS ChangeLog NEWS README"
