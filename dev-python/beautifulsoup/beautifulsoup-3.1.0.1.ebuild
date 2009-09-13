# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/beautifulsoup/beautifulsoup-3.1.0.1.ebuild,v 1.2 2009/09/08 19:57:04 arfrever Exp $

EAPI="2"

NEED_PYTHON="2.3"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils

MY_PN="BeautifulSoup"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="HTML/XML parser for quick-turnaround applications like screen-scraping."
HOMEPAGE="http://www.crummy.com/software/BeautifulSoup/"
SRC_URI="http://www.crummy.com/software/${MY_PN}/download/${MY_P}.tar.gz"

LICENSE="PSF-2.3"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${MY_P}"

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"

src_prepare() {
	python_copy_sources --no-link

	conversion() {
		[[ "${PYTHON_ABI}" == 2.* ]] && return
		epatch "${FILESDIR}/${P}-python-3.patch"
	}
	python_execute_function --action-message 'Applying patches for Python ${PYTHON_ABI}' --failure-message 'Applying patches for Python ${PYTHON_ABI} failed' -s conversion
}

src_test() {
	testing() {
		PYTHONPATH="build/lib" "$(PYTHON)" BeautifulSoupTests.py
	}
	python_execute_function -s testing
}

pkg_postinst() {
	python_mod_optimize BeautifulSoup.py BeautifulSoupTests.py
}
