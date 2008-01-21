# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/silvercity/silvercity-0.9.7.ebuild,v 1.6 2008/01/20 15:45:24 grobian Exp $

EAPI="prefix"

inherit distutils eutils python

DESCRIPTION="A lexical analyser for many languages."
HOMEPAGE="http://silvercity.sourceforge.net/"

MY_P=${P/silvercity/SilverCity}
SRC_URI="mirror://sourceforge/silvercity/${MY_P}.tar.gz"
S=${WORKDIR}/${MY_P}

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=">=dev-lang/python-2.3"

src_install() {
	distutils_src_install

	# remove useless documentation
	rm ${ED}/usr/share/doc/${P}/PKG-INFO.gz

	# fix permissions
	python_version
	chmod 644 ${ED}/usr/$(get_libdir)/python${PYVER}/site-packages/SilverCity/default.css

	# fix CR/LF issue
	find ${ED}/usr/bin -iname "*.py" -exec sed -e 's/\r$//' -i \{\} \;

	# fix path
	dosed -i 's|#!/usr/home/sweetapp/bin/python|#!/usr/bin/env python|' \
		/usr/bin/cgi-styler-form.py || die "dosed failed"
}
