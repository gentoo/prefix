# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/aix-miscutils/aix-miscutils-0.1.1634.ebuild,v 1.1 2009/06/21 13:38:16 grobian Exp $

DESCRIPTION="Miscellaneous helpers for AIX (currently just ldd)"
HOMEPAGE="http://www.gentoo.org/proj/en/gentoo-alt/prefix/"
SRC_URI="http://dev.gentoo.org/~haubi/distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix"
IUSE=""

src_install() {
	emake DESTDIR="${D}" install || die
}
