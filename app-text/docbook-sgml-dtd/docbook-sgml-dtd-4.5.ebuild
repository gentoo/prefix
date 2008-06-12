# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/docbook-sgml-dtd/docbook-sgml-dtd-4.5.ebuild,v 1.2 2007/08/22 16:44:37 mr_bones_ Exp $

EAPI="prefix"

inherit eutils sgml-catalog

MY_P="docbook-${PV}"
DESCRIPTION="Docbook SGML DTD 4.5"
HOMEPAGE="http://www.docbook.org/sgml/"
SRC_URI="http://www.docbook.org/sgml/${PV}/${MY_P}.zip"

LICENSE="X11"
SLOT="4.5"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
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

	epatch "${FILESDIR}/${P}-catalog.diff"
}

src_install () {

	insinto /usr/share/sgml/docbook/sgml-dtd-${PV}
	doins *.dcl *.dtd *.mod *.xml
	newins docbook.cat catalog

	dodoc README
}
