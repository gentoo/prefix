# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pychecker/pychecker-0.8.17.ebuild,v 1.1 2006/02/08 09:03:36 lucass Exp $

EAPI="prefix"

inherit distutils

DESCRIPTION="tool for finding common bugs in python source code"
SRC_URI="mirror://sourceforge/pychecker/${P}.tar.gz"
HOMEPAGE="http://pychecker.sourceforge.net/"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
LICENSE="BSD"
IUSE=""
DEPEND="virtual/python"
DOCS="pycheckrc TODO"

src_install() {
	distutils_src_install
	sed -i -e "s|${D}|/|" "${ED}/usr/bin/pychecker"

	distutils_python_version
	local destdir="${ED}/usr/lib/python${PYVER}/site-packages/${PN}"
	rm ${destdir}/{COPYRIGHT,README,VERSION,CHANGELOG}
	rm ${destdir}/{KNOWN_BUGS,MAINTAINERS,TODO}
}
