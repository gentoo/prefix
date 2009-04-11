# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit distutils

DESCRIPTION="Python module dependency analysis tool"
HOMEPAGE="http://pypi.python.org/pypi/modulegraph/"
SRC_URI="http://pypi.python.org/packages/source/m/modulegraph/${P}.tar.gz"

KEYWORDS="~x86-macos ~ppc-macos"
SLOT="0"
LICENSE="MIT"
IUSE=""

PYTHON_MODNAME=${MY_PN}
