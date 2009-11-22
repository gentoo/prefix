# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/virtualenv/virtualenv-1.4.3.ebuild,v 1.1 2009/11/21 02:53:20 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="Virtual Python Environment builder"
HOMEPAGE="http://pypi.python.org/pypi/virtualenv"
SRC_URI="http://pypi.python.org/packages/source/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
SLOT="0"
IUSE=""

RDEPEND=">=dev-python/setuptools-0.6_rc8"
DEPEND="${RDEPEND}"
# 2.7: Bug #292409
RESTRICT_PYTHON_ABIS="2.7 3.*"

PYTHON_MODNAME="virtualenv.py virtualenv_support"
DOCS="docs/index.txt docs/news.txt"
