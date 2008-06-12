# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/dnspython/dnspython-1.3.5.ebuild,v 1.12 2007/12/15 11:34:12 lucass Exp $

EAPI="prefix"

inherit distutils

DESCRIPTION="DNS toolkit for Python."
HOMEPAGE="http://www.dnspython.org/"
SRC_URI="http://www.dnspython.org/kits/${PV}/${P}.tar.gz"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND="virtual/python
	sys-devel/make"

src_install() {
	distutils_src_install
	dodoc TODO
	dodir /usr/share/doc/${P}

	cp -r examples ${D}/usr/share/doc/${P}
	dodir /usr/share/${PN}
	cp -r tests ${D}/usr/share/${PN}
}

pkg_postinst() {
	elog "Documentation is sparse at the moment. Use pydoc,"
	elog "or read the HTML documentation at the dnspython's home page."
}

src_test() {
	export PYTHONPATH="${S}/build/lib:${PYTHONPATH}"
	cd tests
	make || die "Unit tests failed!"
}
