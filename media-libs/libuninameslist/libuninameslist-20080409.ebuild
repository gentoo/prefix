# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libuninameslist/libuninameslist-20080409.ebuild,v 1.10 2009/03/15 18:17:39 armin76 Exp $

DESCRIPTION="Library of unicode annotation data"
HOMEPAGE="http://libuninameslist.sourceforge.net/"
SRC_URI="mirror://sourceforge/libuninameslist/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

S=${WORKDIR}/${PN}

src_install() {
	emake DESTDIR="${D}" install || die
}
