# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/album/album-4.02.ebuild,v 1.7 2007/06/29 21:59:06 pylon Exp $

DESCRIPTION="HTML photo album generator"
HOMEPAGE="http://MarginalHacks.com/Hacks/album/"
SRC_URI="http://marginalhacks.com/bin/album.versions/${P}.tar.gz"

LICENSE="marginalhacks"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="ffmpeg"

DEPEND="virtual/libc"
RDEPEND="dev-lang/perl
	media-gfx/imagemagick
	media-gfx/jhead
	ffmpeg? ( media-video/ffmpeg )"

src_install() {
	dobin album
	doman album.1
	dohtml Documentation.html
	dodoc License.txt
}

pkg_postinst() {
	elog "For some optional themes please browse:"
	elog "http://MarginalHacks.com/Hacks/album/Themes/"
	elog
	elog "For some optional tools please browse:"
	elog "http://MarginalHacks.com/Hacks/album/tools/"
}
