# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/mysql-python/mysql-python-1.2.2.ebuild,v 1.9 2008/02/05 09:52:56 jer Exp $

NEED_PYTHON=2.3

inherit distutils eutils

MY_P="MySQL-python-${PV}"
DESCRIPTION="MySQL Module for python"
HOMEPAGE="http://sourceforge.net/projects/mysql-python/"
SRC_URI="mirror://sourceforge/mysql-python/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND="virtual/mysql"
DEPEND="${RDEPEND}
	dev-python/setuptools"

S="${WORKDIR}/${MY_P}"
DOCS="HISTORY doc/FAQ.txt doc/MySQLdb.txt"

src_unpack() {
	distutils_src_unpack
	cd "${S}"
	epatch "${FILESDIR}"/${P}-darwin.patch
}
