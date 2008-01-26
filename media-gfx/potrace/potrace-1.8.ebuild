# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/potrace/potrace-1.8.ebuild,v 1.2 2007/12/31 18:31:59 mr_bones_ Exp $

EAPI="prefix"

DESCRIPTION="Transforming bitmaps into vector graphics"
HOMEPAGE="http://potrace.sourceforge.net/"
SRC_URI="http://potrace.sourceforge.net/download/${P}.tar.gz"

LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"

IUSE="metric"

src_compile() {
	econf \
		--enable-zlib\
		$(use_enable metric a4) \
		$(use_enable metric) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."

	dodoc AUTHORS NEWS README
}
