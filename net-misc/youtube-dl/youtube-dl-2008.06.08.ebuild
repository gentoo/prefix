# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/youtube-dl/youtube-dl-2008.06.08.ebuild,v 1.1 2008/06/12 08:41:37 agorf Exp $

EAPI="prefix"

DESCRIPTION="A small command-line program to download videos from YouTube."
HOMEPAGE="http://www.arrakis.es/~rggi3/youtube-dl/"
SRC_URI="http://www.arrakis.es/~rggi3/${PN}/${P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=">=dev-lang/python-2.4"
RDEPEND="${DEPEND}"

src_unpack() {
	:
}

src_install() {
	newbin "${DISTDIR}/${P}" ${PN}
}
