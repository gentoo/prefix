# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/docbook-sgml-dtd/docbook-sgml-dtd-4.4.ebuild,v 1.15 2007/02/11 10:54:10 grobian Exp $

EAPI="prefix"

inherit sgml-catalog eutils

MY_P="docbook-${PV}"
DESCRIPTION="Docbook SGML DTD 4.4"
HOMEPAGE="http://www.docbook.org/sgml/"
SRC_URI="http://www.docbook.org/sgml/${PV}/${MY_P}.zip"

LICENSE="X11"
SLOT="4.4"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND=">=app-arch/unzip-5.41"
RDEPEND="app-text/sgml-common"

S=${WORKDIR}

sgml-catalog_cat_include "${EPREFIX}/etc/sgml/sgml-docbook-${PV}.cat" \
	"${EPREFIX}/usr/share/sgml/docbook/sgml-dtd-${PV}/catalog"
sgml-catalog_cat_include "${EPREFIX}/etc/sgml/sgml-docbook-${PV}.cat" \
	"${EPREFIX}/etc/sgml/sgml-docbook.cat"

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/${P}-catalog.diff || die
}

src_install () {

	insinto /usr/share/sgml/docbook/sgml-dtd-${PV}
	doins *.dcl *.dtd *.mod
	newins docbook.cat catalog

	dodoc ChangeLog README
}
