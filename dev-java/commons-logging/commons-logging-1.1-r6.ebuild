# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-logging/commons-logging-1.1-r6.ebuild,v 1.1 2008/01/30 17:30:30 caster Exp $

EAPI="prefix 1"
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2 java-osgi

DESCRIPTION="The Jakarta-Commons Logging package is an ultra-thin bridge between different logging libraries."
HOMEPAGE="http://jakarta.apache.org/commons/logging/"
SRC_URI="mirror://apache/jakarta/commons/logging/source/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="avalon-logkit log4j servletapi avalon-framework"

COMMON_DEP="
	avalon-logkit? ( dev-java/avalon-logkit:1.2 )
	log4j? ( dev-java/log4j:0 )
	servletapi? ( java-virtuals/servlet-api:2.3 )
	avalon-framework? ( dev-java/avalon-framework:4.2 )"
# ATTENTION: Add this when log4j-1.3 is out
#	=dev-java/log4j-1.3*
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	${COMMON_DEP}"

S="${WORKDIR}/${P}-src/"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-gentoo.patch"
	# patch to make the build.xml respect no servletapi
	# TODO file upstream -nichoj
	epatch "${FILESDIR}/${P}-servletapi.patch"

	# bug 200918
	java-ant_ignore-system-classes

	# bug #208098
	echo "jdk.1.4.present=true" > build.properties
	use log4j && echo "log4j12.jar=$(java-pkg_getjars log4j)" >> build.properties
	# ATTENTION: Add this when log4j-1.3 is out (check the SLOT)
	#echo "log4j13.jar=$(java-pkg_getjars log4j-1.3)" > build.properties
	use avalon-logkit && echo "logkit.jar=$(java-pkg_getjars avalon-logkit-1.2)" >> build.properties
	use servletapi && echo "servletapi.jar=$(java-pkg_getjar --virtual servlet-api-2.3 servlet.jar)" >> build.properties
	use avalon-framework && echo "avalon-framework.jar=$(java-pkg_getjars avalon-framework-4.2)" >> build.properties
	java-pkg_filter-compiler jikes ecj-3.2
}

EANT_BUILD_TARGET="compile"

src_install() {
	java-osgi_newjar-fromfile "target/${P}.jar" "${FILESDIR}/${P}-manifest" "Apache Commons Logging"
	java-pkg_newjar target/${PN}-api-${PV}.jar ${PN}-api.jar
	java-pkg_newjar target/${PN}-adapters-${PV}.jar ${PN}-adapters.jar

	dodoc RELEASE-NOTES.txt || die
	dohtml PROPOSAL.html STATUS.html || die
	use doc && java-pkg_dojavadoc target/docs/
	use source && java-pkg_dosrc src/java/org
}
