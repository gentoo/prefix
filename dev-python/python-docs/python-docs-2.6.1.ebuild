# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-docs/python-docs-2.6.1.ebuild,v 1.1 2008/12/24 20:28:56 neurogeek Exp $

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

S="${WORKDIR}/python-docs-html"

src_install() {
	docinto html
	cp -R [a-z]* _static "${ED}/usr/share/doc/${PF}/html"
}

pkg_preinst() {
	dodir /etc/env.d
	echo "PYTHONDOCS=${EPREFIX}/usr/share/doc/${PF}/html/library" > "${ED}/etc/env.d/50python-docs"
}
