# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pychecker/pychecker-0.8.18.ebuild,v 1.1 2009/01/04 19:46:19 patrick Exp $

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
	epatch "${FILESDIR}"/pychecker-0.8.17-no-data-files.patch
	epatch "${FILESDIR}"/pychecker-0.8.18-pychecker2.patch
}

src_install() {
	distutils_src_install
	sed -i -e "s|${D}|/|" "${ED}/usr/bin/pychecker"
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/
}

pkg_postrm() {
	python_version
	python_mod_cleanup /usr/$(get_libdir)/python${PYVER}/site-packages/
}
