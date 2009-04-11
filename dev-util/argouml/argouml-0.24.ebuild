# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/argouml/argouml-0.24.ebuild,v 1.3 2008/08/30 14:33:07 ranger Exp $

inherit java-pkg-2

DESCRIPTION="modelling tool that helps you do your design using UML"
HOMEPAGE="http://argouml.tigris.org"
BASE_URI="http://argouml-downloads.tigris.org/nonav/${P}"
SRC_URI="${BASE_URI}/ArgoUML-${PV}.tar.gz
	http://argouml-downloads.tigris.org/nonav/argouml-db-1.0/dbuml-module-1.0.4.zip
	doc? (
		${BASE_URI}/argomanual-${PV}.pdf
		${BASE_URI}/quickguide-${PV}.pdf
		${BASE_URI}/cookbook-${PV}.pdf
	)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc"

DEPEND="app-arch/unzip"
RDEPEND=">=virtual/jre-1.5"

S="${WORKDIR}"

src_compile() { :; }

src_install() {
	java-pkg_jarinto /opt/${PN}/lib
	java-pkg_dojar *.jar

	java-pkg_jarinto /opt/${PN}/lib/ext
	java-pkg_dojar ext/*.jar release/ext/*.jar

	java-pkg_dolauncher ${PN} --main org.argouml.application.Main

	dodoc README.txt || die

	if use doc ; then
		dohtml -r release/{Readme.htm,www} || die
		insinto /usr/share/doc/${P}
		doins "${DISTDIR}/argomanual-${PV}.pdf"
		doins "${DISTDIR}/quickguide-${PV}.pdf"
		doins "${DISTDIR}/cookbook-${PV}.pdf"
	fi
}
