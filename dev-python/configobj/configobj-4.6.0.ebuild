# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/configobj/configobj-4.6.0.ebuild,v 1.1 2009/07/04 15:43:46 arfrever Exp $

NEED_PYTHON="2.4"

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

src_install() {
	distutils_src_install
	if use doc; then
		rm -f docs/BSD*
		insinto /usr/share/doc/${PF}/html
		doins -r docs/* || die
	fi
}

src_test() {
	distutils_python_version
	sed -i \
		-e 's/ \(doctest\.testmod(.*\)/ sys.exit(\1[0] != 0)/' \
		validate.py
	PYTHONPATH=build/lib "${python}" validate.py -v \
		|| die "configobj_test.py failed"
}
