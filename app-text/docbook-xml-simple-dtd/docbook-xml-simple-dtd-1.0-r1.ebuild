# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/docbook-xml-simple-dtd/docbook-xml-simple-dtd-1.0-r1.ebuild,v 1.17 2010/02/11 14:58:30 ulm Exp $

inherit sgml-catalog

MY_PN="docbook-simple"
MY_P=${MY_PN}-${PV}

DESCRIPTION="Simplified Docbook DTD for XML"
HOMEPAGE="http://www.oasis-open.org/docbook/"
SRC_URI="http://www.oasis-open.org/docbook/xml/simple/${PV}/${MY_P}.zip"

LICENSE="as-is"
SLOT="1.0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND="dev-libs/libxml2"
DEPEND=">=app-arch/unzip-5.41
	${RDEPEND}"

S=${WORKDIR}

sgml-catalog_cat_include "/etc/sgml/xml-simple-docbook-${PV}.cat" \
	"/usr/share/sgml/docbook/${P#docbook-}/catalog"

src_install() {
	insinto /usr/share/sgml/docbook/${P#docbook-}
	doins *.dtd *.mod *.css
	newins "${FILESDIR}"/${P}.cat catalog
}
