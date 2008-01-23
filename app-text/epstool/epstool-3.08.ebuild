# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/epstool/epstool-3.08.ebuild,v 1.9 2008/01/22 19:16:47 grobian Exp $

EAPI="prefix"

DESCRIPTION="Creates or extracts preview images in EPS files, fixes bounding boxes,converts to bitmaps."
HOMEPAGE="http://www.cs.wisc.edu/~ghost/gsview/epstool.htm"
SRC_URI="ftp://mirror.cs.wisc.edu/pub/mirrors/ghost/ghostgum/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND="virtual/ghostscript
	!=app-text/gsview-4.6"

src_compile() {
	make epstool || die
}

src_install() {
	dobin bin/epstool
	doman doc/epstool.1
	dohtml doc/epstool.htm doc/gsview.css
}
