# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.4.1.ebuild,v 1.1 2010/03/06 23:43:10 vapier Exp $

inherit libtool autotools

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/libpng/${P}.tar.bz2"

LICENSE="as-is"
SLOT="1.2"
#KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# required to get new/patched libtool, which knows better about eprefix!
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE CHANGES README TODO
}
