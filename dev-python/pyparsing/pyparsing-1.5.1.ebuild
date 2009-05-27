# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyparsing/pyparsing-1.5.1.ebuild,v 1.6 2009/04/05 14:25:54 klausman Exp $

inherit distutils

DESCRIPTION="pyparsing is an easy-to-use Python module for text parsing"
HOMEPAGE="http://pyparsing.wikispaces.com/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE="doc examples"

src_install() {
	distutils_src_install

	dohtml HowToUsePyparsing.html
	dodoc CHANGES

	if use doc; then
		dohtml -r htmldoc/*
		insinto /usr/share/doc/${PF}
		doins docs/*.pdf
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
