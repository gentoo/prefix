# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gnome-themes/gnome-themes-2.26.1.ebuild,v 1.1 2009/05/03 22:34:05 eva Exp $

GCONF_DEBUG="no"

inherit eutils gnome2

DESCRIPTION="A set of GNOME themes, with sets for users with limited or low vision"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="accessibility"

RDEPEND=">=x11-libs/gtk+-2
	 >=x11-themes/gtk-engines-2.15.3"
DEPEND="${RDEPEND}
	>=x11-misc/icon-naming-utils-0.8.7
	>=dev-util/pkgconfig-0.19
	>=dev-util/intltool-0.35"
# dev-perl/XML-LibXML is bug 266136

DOCS="AUTHORS ChangeLog NEWS README"

# This ebuild does not install any binaries
RESTRICT="binchecks strip"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable accessibility all-themes)
		--disable-test-themes
		--enable-icon-mapping"
}

src_unpack() {
	gnome2_src_unpack

	# Fix bashisms, bug #256337
	epatch "${FILESDIR}/${PN}-2.24.3-bashism.patch"
}
