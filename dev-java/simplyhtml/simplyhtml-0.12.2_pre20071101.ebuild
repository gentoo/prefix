# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/simplyhtml/simplyhtml-0.12.2_pre20071101.ebuild,v 1.1 2007/12/10 22:04:31 caster Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2 versionator

# the following commented out stuff is for upsteam release

#MY_PN="shtml"
#MY_PV="$(replace_all_version_separators _)"
#MY_P="${MY_PN}_${MY_PV}"

# cvs instructions
# cvs -d:pserver:anonymous@simplyhtml.cvs.sourceforge.net:/cvsroot/simplyhtml login
# cvs -d:pserver:anonymous@simplyhtml.cvs.sourceforge.net:/cvsroot/simplyhtml export -D 2007-11-01 -d simplyhtml-0.12.2_pre20071101 shtml
# rm simplyhtml-0.12.2_pre20071101/lib/*.jar
# tar -cjf simplyhtml-0.12.2_pre20071101.tar.bz2 simplyhtml-0.12.2_pre20071101

DESCRIPTION="Text processing application based on HTML and CSS files."
HOMEPAGE="http://${PN}.sourceforge.net"
#SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"
SRC_URI="mirror://gentoo/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

COMMON_DEP="dev-java/javahelp
	dev-java/gnu-regexp"
DEPEND=">=virtual/jdk-1.4
	${COMMON_DEP}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

#S="${WORKDIR}/dist"

src_unpack() {
	unpack ${A}
	cd "${S}"

#	rm -rf api || die
#	rm -v lib/*.jar || die
}

JAVA_PKG_FILTER_COMPILER="jikes"

src_compile() {
	cd src || die
	local cp="$(java-pkg_getjars javahelp,gnu-regexp-1)"
	eant -Dclasspath="${cp}" jar $(use_doc)
}

src_install() {
	java-pkg_dojar dist/lib/*.jar

	use doc && java-pkg_dojavadoc dist/api
	use source && java-pkg_dosrc src/com src/de
}
