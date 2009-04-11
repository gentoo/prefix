# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pychecker/pychecker-0.8.17-r1.ebuild,v 1.1 2008/09/01 22:03:58 hawking Exp $

inherit distutils eutils

DESCRIPTION="Tool for finding common bugs in python source code"
SRC_URI="mirror://sourceforge/pychecker/${P}.tar.gz"
HOMEPAGE="http://pychecker.sourceforge.net/"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
LICENSE="BSD"
IUSE=""
DEPEND="virtual/python"
DOCS="pycheckrc"

src_unpack() {
	distutils_src_unpack
	epatch "${FILESDIR}"/${P}-no-data-files.patch
}

src_install() {
	distutils_src_install
	sed -i -e "s|${D}|/|" "${ED}/usr/bin/pychecker"
}
