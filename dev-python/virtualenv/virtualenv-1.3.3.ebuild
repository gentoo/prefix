# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/virtualenv/virtualenv-1.3.3.ebuild,v 1.6 2009/09/27 19:02:05 nixnut Exp $

EAPI="2"

NEED_PYTHON="2.3"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="Virtual Python Environment builder"
HOMEPAGE="http://pypi.python.org/pypi/virtualenv"
SRC_URI="http://pypi.python.org/packages/source/v/${PN}/${P}.tar.gz"
LICENSE="MIT"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
SLOT="0"
IUSE=""

RDEPEND=">=dev-python/setuptools-0.6_rc8"
DEPEND="${RDEPEND}"

RESTRICT_PYTHON_ABIS="3*"

DOCS="docs/index.txt"

src_prepare() {
	rm -f support-files/ez_setup.py
}

pkg_postinst() {
	python_mod_optimize rebuild-script.py refresh-support-files.py virtualenv.py
}

pkg_postrm() {
	python_mod_cleanup
}
