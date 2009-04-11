# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/mikachan-font/mikachan-font-9.1.ebuild,v 1.12 2008/01/15 18:02:43 grobian Exp $

inherit font

MY_PN="${PN/-/}"

DESCRIPTION="Mikachan Japanese TrueType fonts"
# taken from
#SRC_URI="http://mikachan.sourceforge.jp/mikachanALL.exe
#	http://mikachan.sourceforge.jp/puchi.exe"
SRC_URI="mirror://gentoo/${P}.tar.bz2
	http://dev.gentoo.org/~usata/${P}.tar.bz2"
HOMEPAGE="http://mikachan-font.com/"

LICENSE="free-noncomm"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

FONT_SUFFIX="ttc"
