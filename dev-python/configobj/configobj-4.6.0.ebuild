# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/configobj/configobj-4.6.0.ebuild,v 1.2 2009/08/31 23:52:08 arfrever Exp $

EAPI="2"

NEED_PYTHON="2.4"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="Simple config file reader and writer"
HOMEPAGE="http://www.voidspace.org.uk/python/configobj.html"
SRC_URI="mirror://sourceforge/${PN}/${P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc"

DEPEND="app-arch/unzip"
RDEPEND=""

RESTRICT_PYTHON_ABIS="3*"

src_test() {
	sed -i \
		-e 's/ \(doctest\.testmod(.*\)/ sys.exit(\1[0] != 0)/' \
		validate.py

	testing() {
		PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" validate.py -v
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install
	if use doc; then
		rm -f docs/BSD*
		insinto /usr/share/doc/${PF}/html
		doins -r docs/* || die
	fi
}

pkg_postinst() {
	python_mod_optimize configobj.py validate.py
}

pkg_postrm() {
	python_mod_cleanup
}
