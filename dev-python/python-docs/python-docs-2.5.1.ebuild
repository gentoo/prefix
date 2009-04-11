# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-docs/python-docs-2.5.1.ebuild,v 1.10 2008/11/04 03:26:23 vapier Exp $

DESCRIPTION="HTML documentation for Python"
HOMEPAGE="http://www.python.org/doc/${PV}/"
SRC_URI="http://www.python.org/ftp/python/doc/${PV}/html-${PV}.tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.5"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}

src_unpack() {
	unpack html-${PV}.tar.bz2
	rm -f README python.dir
}

src_install() {
	docinto html
	cp -R "${S}"/Python-Docs-${PV}/* ${ED}/usr/share/doc/${PF}/html
}

pkg_preinst() {
	dodir /etc/env.d
	echo "PYTHONDOCS=${EPREFIX}/usr/share/doc/${PF}/html/lib" > ${ED}/etc/env.d/50python-docs
}
