# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/silvercity/silvercity-0.9.7.ebuild,v 1.8 2009/10/03 05:09:11 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils python

MY_PN="SilverCity"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A lexical analyser for many languages."
HOMEPAGE="http://silvercity.sourceforge.net/"
SRC_URI="mirror://sourceforge/silvercity/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""
RDEPEND=""
RESTRICT_PYTHON_ABIS="3.*"

S="${WORKDIR}/${MY_P}"

PYTHON_MODNAME="${MY_PN}"

src_install() {
	distutils_src_install

	# Remove useless documentation.
	rm "${ED}usr/share/doc/${P}/PKG-INFO"*

	# Fix permissions.
	chmod 644 "${ED}"usr/$(get_libdir)/python*/site-packages/SilverCity/default.css

	# Fix CR/LF issue.
	find "${ED}usr/bin" -iname "*.py" -exec sed -e 's/\r$//' -i \{\} \;

	# Fix path.
	dosed -i 's|#!/usr/home/sweetapp/bin/python|#!/usr/bin/env python|' \
		/usr/bin/cgi-styler-form.py || die "dosed failed"
}
