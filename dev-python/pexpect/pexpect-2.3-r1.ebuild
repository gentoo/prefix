# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pexpect/pexpect-2.3-r1.ebuild,v 1.1 2009/08/28 20:07:43 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="Python module for spawning child applications and responding to expected patterns"
HOMEPAGE="http://pexpect.sourceforge.net/"
SRC_URI="mirror://sourceforge/pexpect/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc examples"

DEPEND=""
RDEPEND=""

RESTRICT_PYTHON_ABIS="3*"

src_install() {
	distutils_src_install

	use doc && dohtml -r doc/*

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

pkg_postinst() {
	python_mod_optimize ANSI.py fdpexpect.py FSM.py pexpect.py pxssh.py screen.py
}

pkg_postrm() {
	python_mod_cleanup
}
