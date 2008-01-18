# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xerces/xerces-2.9.1.ebuild,v 1.2 2008/01/17 14:39:12 caster Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc examples source"

inherit eutils versionator java-pkg-2 java-ant-2

DIST_PN="Xerces-J"
SRC_PV="$(replace_all_version_separators _ )"
DESCRIPTION="The next generation of high performance, fully compliant XML parsers in the Apache Xerces family"
HOMEPAGE="http://xml.apache.org/xerces2-j/index.html"
SRC_URI="mirror://apache/${PN}/j/${DIST_PN}-src.${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="2"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

# ships with external-1.3.04, need slot dep with lower limit
COMMON_DEP="=dev-java/xml-commons-external-1.3*
	>=dev-java/xml-commons-resolver-1.2
	dev-java/xalan-serializer"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/xjavac-20041208-r4
	${COMMON_DEP}"

S="${WORKDIR}/${PN}-${SRC_PV}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-gentoo.patch"
	epatch "${FILESDIR}/${P}-no_dom3.patch"
	java-ant_rewrite-classpath
}

src_compile() {
	# known small bug - javadocs use custom taglets, which come as bundled jar in xerces-J-tools.2.8.0.tar.gz
	# ommiting them causes non-fatal errors in javadocs generation
	# need to either find the taglets source, use the bundled jars as it's only compile-time or remove the taglet defs from build.xml
	ANT_TASKS="xjavac-1" eant -Dgentoo.classpath="$(java-pkg_getjars xml-commons-resolver,xml-commons-external-1.3,xalan-serializer)" \
		jar $(use_doc javadocs)
}

src_install() {
	java-pkg_dojar build/xercesImpl.jar

	dodoc README NOTICE || die
	dohtml Readme.html || die

	use doc && java-pkg_dojavadoc build/docs/javadocs/xerces2
	use examples && java-pkg_doexamples samples
	use source && java-pkg_dosrc "${S}/src/org"
}
