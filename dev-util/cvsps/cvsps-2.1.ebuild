# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cvsps/cvsps-2.1.ebuild,v 1.13 2007/05/01 17:18:05 grobian Exp $

EAPI="prefix"

MY_P="${P/_/}"
S="${WORKDIR}/${MY_P}"
DESCRIPTION="Generates patchset information from a CVS repository"
HOMEPAGE="http://www.cobite.com/cvsps/"
SRC_URI="http://www.cobite.com/cvsps/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~mips ~ppc-macos ~x86"
IUSE=""

DEPEND="sys-libs/zlib"

src_install() {
	dobin cvsps
	doman cvsps.1
	dodoc README CHANGELOG COPYING
}
