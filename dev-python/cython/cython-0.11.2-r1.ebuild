# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/cython/cython-0.11.2-r1.ebuild,v 1.2 2009/08/12 15:59:39 arfrever Exp $

EAPI="2"

NEED_PYTHON="2.2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils flag-o-matic

MY_PN="Cython"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A language for writing Python extension modules based on pyrex"
HOMEPAGE="http://www.cython.org/"
SRC_URI="http://www.cython.org/${MY_P}.tar.gz"

LICENSE="PSF-2.4"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="doc examples"

DEPEND=""
RDEPEND=""

RESTRICT_PYTHON_ABIS="3*"

S="${WORKDIR}/${MY_P}"

PYTHON_MODNAME="${MY_PN}"
DOCS="ToDo.txt USAGE.txt"

pkg_setup() {
	if use amd64; then
		# Tests fail with some optimizations.
		replace-flags -O[2-9s]* -O1
	fi
}

src_test() {
	python_execute_function -d
}

src_install() {
	distutils_src_install

	# -A c switch is for Doc/primes.c
	use doc && dohtml -A c -r Doc/*

	if use examples; then
		# Demos/ has files with .so,~ suffixes.
		# So we have to specify precisely what to install.
		insinto /usr/share/doc/${PF}/examples
		doins Demos/Makefile* Demos/setup.py Demos/*.{py,pyx}
	fi
}
