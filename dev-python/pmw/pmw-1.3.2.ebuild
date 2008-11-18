# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pmw/pmw-1.3.2.ebuild,v 1.2 2008/08/06 15:28:53 mr_bones_ Exp $

EAPI="prefix"

PYTHON_MODNAME="Pmw"

inherit distutils

MY_P="Pmw.${PV}"

DESCRIPTION="A toolkit for building high-level compound widgets in Python using the Tkinter module."
HOMEPAGE="http://pmw.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
LICENSE="BSD"
IUSE="doc examples"

DEPEND="virtual/python"

DOCS="${PYTHON_MODNAME}/README"
S="${WORKDIR}/${MY_P}/src"

pkg_setup() {
	# check for Tkinter support in python
	distutils_python_tkinter
}

src_unpack() {
	distutils_src_unpack
	epatch "${FILESDIR}/${P}-install-no-docs.patch"
}

src_install() {
	distutils_src_install

	local DIR
	DIR="${S}/${PYTHON_MODNAME}/Pmw_1_3"

	if use doc; then
		dohtml -a html,gif,py "${DIR}"/doc/* \
			|| die "failed to install docs"
	fi

	if use examples; then
		insinto "${EROOT}/usr/share/doc/${PF}/examples"
		doins "${DIR}"/demos/* \
			|| die "failed to install demos"
	fi

	#Tests are not unittests and show various
	#GUIs. So we don't run them in the ebuild

}
