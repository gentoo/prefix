# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/jpegpixi/jpegpixi-1.1.1.ebuild,v 1.3 2008/01/26 15:08:50 grobian Exp $

DESCRIPTION="almost lossless JPEG pixel interpolator, for correcting digital camera defects."
HOMEPAGE="http://www.zero-based.org/software/jpegpixi/"
SRC_URI="http://www.zero-based.org/software/jpegpixi/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="media-libs/jpeg"

src_install () {
	insinto /usr/bin
	dobin jpegpixi jpeghotp

	doman man/jpegpixi.1 man/jpeghotp.1

	dodoc AUTHORS NEWS README README.jpeglib ChangeLog
}
