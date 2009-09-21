# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-zope/zopeinterface/zopeinterface-3.5.2.ebuild,v 1.4 2009/09/18 23:23:13 maekke Exp $

EAPI="2"

NEED_PYTHON="2.5"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

MY_PN="zope.interface"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Zope 3 Interface Infrastructure"
HOMEPAGE="http://pypi.python.org/pypi/zope.interface"
SRC_URI="http://pypi.python.org/packages/source/${PN:0:1}/${MY_PN}/${MY_P}.tar.gz"
LICENSE="ZPL"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND=""
DEPEND="dev-python/setuptools
	!net-zope/zodb"

RESTRICT_PYTHON_ABIS="3*"

PYTHON_MODNAME="zope/interface"

S="${WORKDIR}/${MY_P}"

src_install() {
	DOCS="CHANGES.txt README.txt src/zope/interface/*.txt"
	distutils_src_install
	rm -fr "${ED}$(python_get_sitedir)/zope/interface"/{tests,common/tests,*.txt,*.c}
}
