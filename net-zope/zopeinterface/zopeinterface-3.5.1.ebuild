# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-zope/zopeinterface/zopeinterface-3.5.1.ebuild,v 1.1 2009/05/16 22:55:04 arfrever Exp $

NEED_PYTHON="2.5"

inherit distutils

MY_PN="zope.interface"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Zope 3 Interface Infrastructure"
HOMEPAGE="http://pypi.python.org/pypi/${MY_PN}"
SRC_URI="http://pypi.python.org/packages/source/${PN:0:1}/${MY_PN}/${MY_P}.tar.gz"
LICENSE="ZPL"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-python/setuptools"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

src_install() {
	DOCS="CHANGES.txt README.txt src/zope/interface/*.txt"
	distutils_src_install
	rm -fr "${ED}$(python_get_sitedir)/zope/interface"/{tests,common/tests,*.txt,*.c}
}
