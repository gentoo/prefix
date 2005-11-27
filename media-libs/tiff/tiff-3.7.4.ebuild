# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/tiff/tiff-3.7.4.ebuild,v 1.1 2005/09/30 02:38:24 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Library for manipulation of TIFF (Tag Image File Format) images"
HOMEPAGE="http://www.libtiff.org/"
SRC_URI="ftp://ftp.remotesensing.org/pub/libtiff/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="jpeg nocxx zlib"

DEPEND="jpeg? ( >=media-libs/jpeg-6b )
	zlib? ( >=sys-libs/zlib-1.1.3-r2 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-assign-dont-compare.patch
}

src_compile() {
	econf \
		$(use_enable !nocxx cxx) \
		$(use_enable zlib) \
		$(use_enable jpeg) \
		--without-x \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make install DESTDIR="${DEST}" || die "make install failed"
	dodoc README TODO VERSION
}
