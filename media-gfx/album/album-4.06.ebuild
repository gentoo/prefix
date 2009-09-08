# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/album/album-4.06.ebuild,v 1.1 2009/09/05 14:31:03 maekke Exp $

DATA_URI="http://marginalhacks.com/bin/album.versions/data-4.05.tar.gz"
DESCRIPTION="HTML photo album generator"
HOMEPAGE="http://MarginalHacks.com/Hacks/album/"
SRC_URI="http://marginalhacks.com/bin/album.versions/${P}.tar.gz
	themes? ( ${DATA_URI} )
	plugins? ( ${DATA_URI} )"

LICENSE="marginalhacks"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="doc ffmpeg plugins themes"

DEPEND="virtual/libc"
RDEPEND="dev-lang/perl
	media-gfx/imagemagick
	media-gfx/jhead
	ffmpeg? ( media-video/ffmpeg )"

src_install() {
	dobin album
	doman album.1
	dodoc License.txt
	use doc && dohtml -r Docs/*

	dodir /usr/share/album
	insinto /usr/share/album
	cd ..
	doins -r lang
	use themes && doins -r Themes
	use plugins && doins -r plugins
}

pkg_postinst() {
	elog "For some optional tools please browse:"
	elog "http://MarginalHacks.com/Hacks/album/tools/"
}
