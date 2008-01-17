# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygoogle/pygoogle-0.6.ebuild,v 1.5 2006/04/01 15:21:23 agriffis Exp $

EAPI="prefix"

inherit distutils

DESCRIPTION="A Python wrapper for the Google web API"
SRC_URI="mirror://sourceforge/pygoogle/${P}.tar.gz"
HOMEPAGE="http://pygoogle.sourceforge.net/"

IUSE=""
SLOT="0"
LICENSE="PYTHON"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"

DEPEND="virtual/python
	>=dev-python/soappy-0.11.3"

src_install() {
	distutils_src_install
	cd doc && dohtml -r * && cd ..
	dodoc readme.txt
}
