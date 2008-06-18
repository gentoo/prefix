# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-dbcp/commons-dbcp-1.2.2.ebuild,v 1.8 2008/01/27 19:22:53 betelgeuse Exp $

EAPI="prefix 1"
JAVA_PKG_IUSE="doc source test"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Jakarta component providing database connection pooling API"
HOMEPAGE="http://jakarta.apache.org/commons/dbcp/"
SRC_URI="mirror://apache/jakarta/commons/dbcp/source/${P}-src.tar.gz"
COMMON_DEP=">=dev-java/commons-pool-1.3"
RDEPEND=">=virtual/jre-1.4
		${COMMON_DEP}"
# FIXME doesn't like jdbc API changes with Java 1.6
DEPEND="|| (
			=virtual/jdk-1.5*
			=virtual/jdk-1.4*
		)
		test? (
			dev-java/junit:0
			www-servers/tomcat:6
			dev-java/xerces:2
		)
		${COMMON_DEP}"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
S="${WORKDIR}/${P}-src"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	echo "commons-pool.jar=$(java-pkg_getjars commons-pool)" >> build.properties
	rm -v *.jar || die
}

EANT_BUILD_TARGET="build-jar"

src_test() {
	eant test -Djunit.jar="$(java-pkg_getjars junit)" \
		-Dnaming-java.jar="$(java-pkg_getjar tomcat-6 catalina.jar)" \
		-Dxerces.jar="$(java-pkg_getjars xerces-2)"
}

src_install() {
	java-pkg_dojar dist/${PN}*.jar || die "Unable to install"
	dodoc README.txt RELEASE-NOTES.txt || die
	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/*
}
