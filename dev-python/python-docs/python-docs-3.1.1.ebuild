# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-docs/python-docs-3.1.1.ebuild,v 1.2 2009/09/27 18:39:53 arfrever Exp $

DESCRIPTION="HTML documentation for Python"
HOMEPAGE="http://www.python.org/doc/"
SRC_URI="http://www.python.org/ftp/python/doc/${PV}/python-${PV}-docs-html.tar.bz2"

LICENSE="PSF-2.2"
SLOT="3.1"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=">=app-admin/eselect-python-20090606"
RDEPEND="${DEPEND}"

S="${WORKDIR}/python-${PV}-docs-html"

src_install() {
	docinto html
	cp -R [a-z]* _static "${ED}/usr/share/doc/${PF}/html"

	echo "PYTHONDOCS_${SLOT//./_}=\"${EPREFIX}/usr/share/doc/${PF}/html/library\"" > "60python-docs-${SLOT}"
	doenvd "60python-docs-${SLOT}"
}

eselect_python_update() {
	local ignored_python_slots
	[[ "$(eselect python show)" == "python2."* ]] && ignored_python_slots="--ignore 3.0 --ignore 3.1 --ignore 3.2"

	# Create python3 symlink.
	eselect python update > /dev/null

	eselect python update ${ignored_python_slots}
}

pkg_postinst() {
	eselect_python_update
}

pkg_postrm() {
	eselect_python_update

	if ! has_version "<dev-python/python-docs-${SLOT}_alpha" && ! has_version ">=dev-python/python-docs-${SLOT%.*}.$((${SLOT#*.}+1))_alpha"; then
		rm -f "${EROOT}etc/env.d/65python-docs"
	fi
}
