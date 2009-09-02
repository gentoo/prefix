# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libmaa/libmaa-1.1.1.ebuild,v 1.9 2009/06/13 14:01:22 armin76 Exp $

DESCRIPTION="Library with low-level data structures which are helpful for writing compilers"
HOMEPAGE="http://www.dict.org/"
SRC_URI="mirror://sourceforge/dict/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog NEWS README doc/libmaa.600dpi.ps || die
}
