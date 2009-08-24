# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/docbook-xml-simple-dtd/docbook-xml-simple-dtd-4.1.2.4-r2.ebuild,v 1.19 2009/08/23 15:52:47 flameeyes Exp $

inherit sgml-catalog

MY_P="sdb4124"
DESCRIPTION="Docbook DTD for XML"
HOMEPAGE="http://www.oasis-open.org/docbook/"
SRC_URI="mirror://gentoo/${MY_P}.zip"

LICENSE="X11"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND=">=app-arch/unzip-5.41"
RDEPEND=""

sgml-catalog_cat_include "/etc/sgml/xml-simple-docbook-${PV}.cat" \
	"/usr/share/sgml/docbook/${P#docbook-}/catalog"

S=${WORKDIR}

src_install() {
	insinto /usr/share/sgml/docbook/${P#docbook-}
	doins *.dtd *.mod *.css

	newins "${FILESDIR}"/${P}.catalog catalog

	insinto /usr/share/sgml/docbook/${P#docbook-}/ent
	doins ent/*.ent

	dodoc README ChangeLog LostLog COPYRIGHT
}
