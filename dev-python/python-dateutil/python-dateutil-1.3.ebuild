# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-dateutil/python-dateutil-1.3.ebuild,v 1.2 2008/06/18 14:27:36 coldwind Exp $

NEED_PYTHON=2.3

inherit distutils

DESCRIPTION="dateutil datetime math and logic library for python"
HOMEPAGE="http://labix.org/python-dateutil"
SRC_URI="http://labix.org/download/python-dateutil/${P}.tar.bz2"

LICENSE="PSF-2.3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="!<=dev-python/matplotlib-0.82"

DOCS="NEWS example.py sandbox/rrulewrapper.py sandbox/scheduler.py"

PYTHON_MODNAME="${PN/python-/}"

src_test() {
	"${python}" test.py
}
