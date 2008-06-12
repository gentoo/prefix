# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-cdb/python-cdb-0.32-r1.ebuild,v 1.4 2008/01/17 18:40:26 grobian Exp $

EAPI="prefix"

inherit distutils eutils

DESCRIPTION="A Python extension module for cdb"
SRC_URI="http://pilcrow.madison.wi.us/python-cdb/${P}.tar.gz"
HOMEPAGE="http://pilcrow.madison.wi.us/#pycdb"

SLOT="0"
IUSE=""
LICENSE="GPL-2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"

DEPEND=">=dev-lang/python-2.2
	dev-db/cdb"
RDEPEND="${DEPEND}"

DOCS="Example"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-python-2.5-compat.patch"
}

src_test() {
	"${python}" setup.py install --home "${T}/test"
	# This is not really intended as test but it is better than nothing.
	PYTHONPATH="${T}/test/lib/python" "${python}" < Example || \
		die "Test failed."
	rm -rf "${T}/test"
}
