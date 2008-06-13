# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gnet/gnet-2.0.7-r1.ebuild,v 1.7 2008/04/12 18:35:45 dertobi123 Exp $

EAPI="prefix"

inherit gnome2 eutils

DESCRIPTION="A simple network library."
HOMEPAGE="http://www.gnetlibrary.org/"
SRC_URI="http://www.gnetlibrary.org/src/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"

IUSE="doc"

RDEPEND=">=dev-libs/glib-1.2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( >=dev-util/gtk-doc-1.2 )"

DOCS="AUTHORS BUGS ChangeLog HACKING NEWS README* TODO"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix integer size mismatches on 64-bit arches
	epatch "${FILESDIR}/${P}-amd64-fixes.patch"
}
