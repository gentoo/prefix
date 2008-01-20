# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xom/xom-1.0-r6.ebuild,v 1.1 2008/01/19 17:04:01 betelgeuse Exp $

JAVA_PKG_IUSE="doc examples source"
EAPI="prefix 1"

inherit java-pkg-2 java-ant-2

XOMVER="xom-${PV/_beta/b}"
DESCRIPTION="A new XML object model."
HOMEPAGE="http://cafeconleche.org/XOM/index.html"
SRC_URI="http://cafeconleche.org/XOM/${XOMVER}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE=""

COMMON_DEPEND="dev-java/xerces:2
		dev-java/xalan:0
		dev-java/junit:0
		dev-java/icu4j:0
		examples? ( dev-java/servletapi:2.4 )"
RDEPEND=">=virtual/jre-1.4
		${COMMON_DEPEND}"
DEPEND=">=virtual/jdk-1.4
		${COMMON_DEPEND}"

S=${WORKDIR}/XOM

src_unpack() {
	unpack ${A}
	cd "${S}"
	java-ant_ignore-system-classes
	rm -v *.jar || die
	cd "${S}/lib"
	rm -v *.jar || die
	java-pkg_jar-from junit
	java-pkg_jar-from xalan
	java-pkg_jar-from xerces-2
	java-pkg_jar-from icu4j icu4j.jar normalizer.jar
	# tagsoup is only needed to run betterdoc but we use the pregenerated ones
}

src_compile() {
	ant_flags="-Ddebug=off"
	use examples && ant_flags="${ant_flags} -Dservlet.jar=$(java-pkg_getjar servletapi-2.4 servlet-api.jar)"

	eant jar ${ant_flags}\
		$(use examples && echo samples)
}

src_install() {
	java-pkg_newjar build/${XOMVER}.jar ${PN}.jar
	use examples && java-pkg_dojar build/xom-samples.jar
	dodoc Todo.txt || die

	use doc && java-pkg_dojavadoc apidocs/
	use source && java-pkg_dosrc src/*
	use examples && java-pkg_doexamples --subdir nu/xom/samples src/nu/xom/samples
}
