# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/fribidi/fribidi-0.10.7.ebuild,v 1.14 2007/05/08 18:53:39 grobian Exp $

EAPI="prefix"

DESCRIPTION="A free implementation of the unicode bidirectional algorithm"
HOMEPAGE="http://fribidi.org/"
SRC_URI="http://fribidi.org/download/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86"
IUSE=""

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS NEWS README ChangeLog THANKS TODO
}
