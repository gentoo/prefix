# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-docs/python-docs-2.6.2.ebuild,v 1.2 2009/05/22 22:39:24 arfrever Exp $

EAPI=2

DESCRIPTION="HTML documentation for Python"
HOMEPAGE="http://www.python.org/doc/"
SRC_URI="http://www.python.org/ftp/python/doc/${PV}/python-${PV}-docs-html.tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.6"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/python-${PV}-docs-html"

src_install() {
	docinto html
	cp -R [a-z]* _static "${ED}/usr/share/doc/${PF}/html"
}

pkg_postinst() {
	echo "PYTHONDOCS=${EPREFIX}/usr/share/doc/${PF}/html/library" > "${EROOT}etc/env.d/50python-docs"
}

pkg_postrm() {
	if ! has_version "<dev-python/python-docs-2.6" && ! has_version ">=dev-python/python-docs-2.7"; then
		rm -f "${EROOT}etc/env.d/50python-docs"
	fi
}
