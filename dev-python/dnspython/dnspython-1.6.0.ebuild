# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/dnspython/dnspython-1.6.0.ebuild,v 1.5 2008/05/12 14:27:17 corsair Exp $

EAPI="prefix"

NEED_PYTHON=2.2

inherit distutils

DESCRIPTION="DNS toolkit for Python"
HOMEPAGE="http://www.dnspython.org/"
SRC_URI="http://www.dnspython.org/kits/${PV}/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE="examples"

DOCS="TODO"

src_install() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi

	insinto /usr/share/${PN}
	doins -r tests
}

src_test() {
	export PYTHONPATH="${S}/build/lib:${PYTHONPATH}"
	cd tests
	emake || die "Unit tests failed!"
}

pkg_postinst() {
	elog "Documentation is sparse at the moment. Use pydoc,"
	elog "or read the HTML documentation at the dnspython's home page."
}
