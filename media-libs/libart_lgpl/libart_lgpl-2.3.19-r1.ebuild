# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libart_lgpl/libart_lgpl-2.3.19-r1.ebuild,v 1.12 2007/09/09 14:02:34 drac Exp $

inherit gnome2 eutils

DESCRIPTION="a LGPL version of libart"
HOMEPAGE="http://www.levien.com/libart"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-util/pkgconfig"
RDEPEND=""

DOCS="AUTHORS ChangeLog NEWS README"

# in prefix, einstall is broken for this package (misses --libdir)
USE_DESTDIR="yes"

src_unpack() {
	gnome2_src_unpack

	epatch "${FILESDIR}"/${P}-alloc.patch
	# Fix crosscompiling; bug #185684
	epatch "${FILESDIR}"/${P}-crosscompile.patch
}
