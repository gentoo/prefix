# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/beautifulsoup/beautifulsoup-3.0.7.ebuild,v 1.4 2009/04/27 19:28:36 maekke Exp $

NEED_PYTHON="2.3"

inherit distutils

MY_PN=BeautifulSoup
MY_P=${MY_PN}-${PV}

DESCRIPTION="HTML/XML parser for quick-turnaround applications like screen-scraping."
HOMEPAGE="http://www.crummy.com/software/BeautifulSoup/"
SRC_URI="http://www.crummy.com/software/${MY_PN}/download/${MY_P}.tar.gz"
LICENSE="PSF-2.3"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

S=${WORKDIR}/${MY_P}

src_test() {
	PYTHONPATH="." "${python}" BeautifulSoupTests.py || die "tests failed"
}
