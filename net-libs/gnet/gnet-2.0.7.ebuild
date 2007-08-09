# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gnet/gnet-2.0.7.ebuild,v 1.11 2007/07/21 20:03:29 remi Exp $

EAPI="prefix"

inherit gnome2 eutils

DESCRIPTION="A simple network library."
HOMEPAGE="http://www.gnetlibrary.org/"
SRC_URI="http://www.gnetlibrary.org/src/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"

IUSE="debug doc static"

RDEPEND=">=dev-libs/glib-1.2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( >=dev-util/gtk-doc-1.2 )"

DOCS="AUTHORS BUGS ChangeLog HACKING NEWS README* TODO"

G2CONF="${G2CONF} $(use_enable static)"

src_unpack() {
	unpack ${A}
	cd ${S}

	# Fix integer size mismatches on 64-bit arches
	epatch ${FILESDIR}/${P}-amd64-fixes.patch
}
