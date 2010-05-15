# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-zope/zope-interface/zope-interface-3.6.1.ebuild,v 1.1 2010/05/06 22:38:49 arfrever Exp $

EAPI="3"
SUPPORT_PYTHON_ABIS="1"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

MY_PN="${PN/-/.}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Interfaces for Python"
HOMEPAGE="http://pypi.python.org/pypi/zope.interface"
SRC_URI="http://pypi.python.org/packages/source/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

# net-zope/zope-fixers is required for building with Python 3.
DEPEND="dev-python/setuptools
	net-zope/zope-fixers"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

PYTHON_MODNAME="${PN/-//}"
DOCS="CHANGES.txt README.txt src/zope/interface/*.txt"

src_install() {
	distutils_src_install
	python_clean_sitedirs
}
