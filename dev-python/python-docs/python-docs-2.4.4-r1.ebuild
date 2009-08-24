# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-docs/python-docs-2.4.4-r1.ebuild,v 1.3 2009/08/24 01:54:57 arfrever Exp $

DESCRIPTION="HTML documentation for Python"
HOMEPAGE="http://www.python.org/doc/"
SRC_URI="http://www.python.org/ftp/python/doc/${PV}/html-${PV}.tar.bz2
http://www.python.org/ftp/python/doc/${PV}/info-${PV}.tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.4"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=">=app-admin/eselect-python-20090606"
RDEPEND="${DEPEND}"

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

	echo "PYTHONDOCS_${SLOT//./_}=\"${EPREFIX}/usr/share/doc/${PF}/html\"" > "60python-docs-${SLOT}"
	doenvd "60python-docs-${SLOT}"
}

pkg_postinst() {
	eselect python update --ignore 3.0 --ignore 3.1 --ignore 3.2
}

pkg_postrm() {
	eselect python update --ignore 3.0 --ignore 3.1 --ignore 3.2

	if ! has_version "<dev-python/python-docs-${SLOT}_alpha" && ! has_version ">=dev-python/python-docs-${SLOT%.*}.$((${SLOT#*.}+1))_alpha"; then
		rm -f "${EROOT}etc/env.d/65python-docs"
	fi

	rm -f "${EROOT}etc/env.d/50python-docs"
}
