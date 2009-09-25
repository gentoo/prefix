# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/urwid/urwid-0.9.8.4.ebuild,v 1.5 2009/09/23 17:53:44 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="Urwid is a curses-based user interface library for Python."
HOMEPAGE="http://excess.org/urwid/"
SRC_URI="http://excess.org/urwid/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="examples"

DEPEND="dev-python/setuptools"
RDEPEND=""
RESTRICT_PYTHON_ABIS="3.*"

src_test() {
	testing() {
		"$(PYTHON)" test_urwid.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	dohtml tutorial.html reference.html

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins bigtext.py browse.py calc.py dialog.py edit.py
		doins fib.py graph.py input_test.py tour.py
	fi
}
