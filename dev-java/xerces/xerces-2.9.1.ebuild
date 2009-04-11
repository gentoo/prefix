# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xerces/xerces-2.9.1.ebuild,v 1.7 2008/03/08 20:26:02 wltjr Exp $

EAPI=1
JAVA_PKG_IUSE="doc examples source"

inherit eutils versionator java-pkg-2 java-ant-2

DIST_PN="Xerces-J"
SRC_PV="$(replace_all_version_separators _ )"
DESCRIPTION="The next generation of high performance, fully compliant XML parsers in the Apache Xerces family"
HOMEPAGE="http://xml.apache.org/xerces2-j/index.html"
SRC_URI="mirror://apache/${PN}/j/${DIST_PN}-src.${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

COMMON_DEP="dev-java/xml-commons-external:1.3
	>=dev-java/xml-commons-resolver-1.2
	dev-java/xalan-serializer"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/xjavac-20041208-r4
	${COMMON_DEP}"

S="${WORKDIR}/${PN}-${SRC_PV}"

# they are missing from the upstream tarball"
RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-gentoo.patch"
	epatch "${FILESDIR}/${P}-no_dom3.patch"
	java-ant_rewrite-classpath
}

# known small bug - javadocs use custom taglets, which come as bundled jar in xerces-J-tools.2.8.0.tar.gz
# ommiting them causes non-fatal errors in javadocs generation
# need to either find the taglets source, use the bundled jars as it's only compile-time or remove the taglet defs from build.xml
EANT_ANT_TASKS="xjavac-1"
EANT_GENTOO_CLASSPATH="xml-commons-resolver,xml-commons-external-1.3,xalan-serializer"
EANT_DOC_TARGET="javadocs"

src_install() {
	java-pkg_dojar build/xercesImpl.jar

	dodoc README NOTICE || die
	dohtml Readme.html || die

	use doc && java-pkg_dojavadoc build/docs/javadocs/xerces2
	use examples && java-pkg_doexamples samples
	use source && java-pkg_dosrc "${S}/src/org"
}
