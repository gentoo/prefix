# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libuninameslist/libuninameslist-20080409.ebuild,v 1.2 2008/06/02 12:21:04 loki_val Exp $

EAPI="prefix"

S=${WORKDIR}/${PN}

DESCRIPTION="Library of unicode annotation data"
SRC_URI="mirror://sourceforge/libuninameslist/${P}.tar.bz2"
HOMEPAGE="http://libuninameslist.sourceforge.net/"

LICENSE="BSD"

SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
DEPEND=""
RDEPEND=""
IUSE=""

src_install() {
	emake DESTDIR="${D}" install
}
