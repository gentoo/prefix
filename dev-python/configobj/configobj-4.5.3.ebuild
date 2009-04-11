# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/configobj/configobj-4.5.3.ebuild,v 1.1 2009/01/14 16:41:11 bicatali Exp $

NEED_PYTHON=2.4

inherit distutils

KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

DESCRIPTION="Simple config file reader and writer"
HOMEPAGE="http://www.voidspace.org.uk/python/configobj.html"
SRC_URI="mirror://sourceforge/${PN}/${P}.zip"
LICENSE="BSD"
SLOT="0"
IUSE="doc"

DEPEND="app-arch/unzip"
RDEPEND=""

DOCS="docs/configobj.txt docs/validate.txt"

src_install() {
	distutils_src_install
	if use doc ; then
		rm -f docs/BSD*
		insinto /usr/share/doc/${PF}/html
		doins -r docs/* || die
	fi
}

src_test() {
	distutils_python_version
	sed -i \
		-e 's/ \(doctest\.testmod(.*\)/ sys.exit(\1[0] != 0)/' \
		configobj_test.py
	PYTHONPATH=build/lib "${python}" configobj_test.py -v \
		|| die "configobj_test.py failed"
}
