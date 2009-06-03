# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libsexy/libsexy-0.1.11-r1.ebuild,v 1.2 2009/05/31 18:52:33 serkan Exp $

EAPI="2"

inherit gnome2 eutils

DESCRIPTION="Sexy GTK+ Widgets"
HOMEPAGE="http://www.chipx86.com/wiki/Libsexy"
SRC_URI="http://releases.chipx86.com/${PN}/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2.6
		 >=x11-libs/gtk+-2.6
		   dev-libs/libxml2
		 >=x11-libs/pango-1.4.0
		 >=app-text/iso-codes-0.49"
DEPEND="${RDEPEND}
		>=dev-lang/perl-5
		>=dev-util/pkgconfig-0.19
		doc? ( >=dev-util/gtk-doc-1.4 )"

DOCS="AUTHORS ChangeLog NEWS README"

src_prepare() {
	epatch "${FILESDIR}"/${P}-fix-null-list.patch
	gnome2_src_prepare
}
