# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-doc/linkers-and-loaders/linkers-and-loaders-1.ebuild,v 1.2 2008/06/28 15:26:38 vapier Exp $

EAPI="prefix"

DESCRIPTION="the Linkers and Loaders book"
HOMEPAGE="http://linker.iecc.com/"
SRC_URI="http://wh0rd.org/${P}.tar.lzma"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="doc"
RESTRICT="mirror"

RDEPEND=""
DEPEND="app-arch/lzma-utils"

S=${WORKDIR}

src_install() {
	dohtml *.html *.jpg || die
	dodoc *.pdf
	use doc && dodoc *.txt *.rtf
}
