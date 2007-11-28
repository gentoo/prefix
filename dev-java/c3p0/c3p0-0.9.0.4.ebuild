# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/c3p0/c3p0-0.9.0.4.ebuild,v 1.7 2007/11/28 03:15:14 betelgeuse Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

SRC_P="${P}.src"

DESCRIPTION="Library for augmenting traditional (DriverManager-based) JDBC drivers with JNDI-bindable DataSources"
HOMEPAGE="http://c3p0.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${SRC_P}.tgz"
# Does not like Java 1.6's JDBC API
COMMON_DEPEND="dev-java/log4j"
DEPEND="|| ( =virtual/jdk-1.5* =virtual/jdk-1.4* )
	${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE=""

S="${WORKDIR}/${SRC_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	echo "j2ee.jar.base.dir=${JAVA_HOME}" > build.properties
	echo "log4j.jar.file=$(java-pkg_getjar log4j log4j.jar)" >> build.properties
}

EANT_DOC_TARGET="javadocs"

src_install() {
	java-pkg_newjar build/${P}.jar
	dodoc README-SRC
	use doc && java-pkg_dojavadoc build/apidocs
	use source && java-pkg_dosrc src/classes/com
}
