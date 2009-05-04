# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyrex/pyrex-0.9.8.5.ebuild,v 1.8 2009/04/20 01:09:21 gentoofan23 Exp $

NEED_PYTHON=2.3

inherit distutils eutils

MY_P="Pyrex-${PV}"
DESCRIPTION="A language for writing Python extension modules"
HOMEPAGE="http://www.cosc.canterbury.ac.nz/~greg/python/Pyrex"
SRC_URI="http://www.cosc.canterbury.ac.nz/~greg/python/Pyrex/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE="examples"

S="${WORKDIR}/${MY_P}"

PYTHON_MODNAME="Pyrex"

# This version doesn't work with older setuptools #218815
RDEPEND="!<dev-python/setuptools-0.6_rc8"

src_install() {
	DOCS="CHANGES.txt ToDo.txt USAGE.txt"
	distutils_src_install

	dohtml -A c -r Doc/*

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r Demos
	fi
}
