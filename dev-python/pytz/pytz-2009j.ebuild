# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pytz/pytz-2009j.ebuild,v 1.1 2009/06/21 02:55:20 arfrever Exp $

EAPI="2"

NEED_PYTHON="2.3"

inherit eutils distutils

DESCRIPTION="World Timezone Definitions for Python"
HOMEPAGE="http://pytz.sourceforge.net/"
SRC_URI="http://cheeseshop.python.org/packages/source/${PN:0:1}/${PN}/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x64-macos ~x86-macos"
IUSE=""

RDEPEND=">=sys-libs/timezone-data-${PV}"
DEPEND="${RDEPEND}"

DOCS="CHANGES.txt"

src_prepare() {
	# Use timezone-data zoneinfo.
	epatch "${FILESDIR}/${PN}-2009j-zoneinfo.patch"
}

src_test() {
	PYTHONPATH=. "${python}" pytz/tests/test_tzinfo.py || die "test failed"
}

src_install() {
	distutils_src_install
	rm -rf "${ED}"/usr/lib*/python*/site-packages/pytz/zoneinfo
}
