# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit distutils

DESCRIPTION="Mach-O header analysis and editing"
HOMEPAGE="http://pypi.python.org/pypi/macholib/"
SRC_URI="http://pypi.python.org/packages/source/m/macholib/${P}.tar.gz"

KEYWORDS="~x86-macos ~ppc-macos"
SLOT="0"
LICENSE="MIT"
IUSE=""

DEPEND=">=dev-python/altgraph-0.6.6
	dev-python/modulegraph"
RDEPEND="${DEPEND}"

PYTHON_MODNAME=${MY_PN}
