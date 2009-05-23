# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-docs/python-docs-2.4.4.ebuild,v 1.14 2009/05/22 22:39:24 arfrever Exp $

DESCRIPTION="HTML documentation for Python"
HOMEPAGE="http://www.python.org/doc/${PV}/"
SRC_URI="http://www.python.org/ftp/python/doc/${PV}/html-${PV}.tar.bz2
http://www.python.org/ftp/python/doc/${PV}/info-${PV}.tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.4"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}

src_unpack() {
	unpack html-${PV}.tar.bz2
	mkdir "${S}/info"
	cd "${S}/info"
	unpack info-${PV}.tar.bz2
	rm -f README python.dir
}

src_install() {
	docinto html
	cp -R "${S}/Python-Docs-${PV}/"* "${ED}/usr/share/doc/${PF}/html"

	insinto /usr/share/info
	doins "${S}/info/"*
}

pkg_postinst() {
	echo "PYTHONDOCS=${EPREFIX}/usr/share/doc/${PF}/html/lib" > "${EROOT}etc/env.d/50python-docs"
}

pkg_postrm() {
	if ! has_version "<dev-python/python-docs-2.4" && ! has_version ">=dev-python/python-docs-2.5"; then
		rm -f "${EROOT}etc/env.d/50python-docs"
	fi
}
