# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xom/xom-1.0-r4.ebuild,v 1.7 2008/01/19 16:55:48 betelgeuse Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc examples source"

inherit java-pkg-2 java-ant-2

XOMVER="xom-${PV/_beta/b}"
DESCRIPTION="A new XML object model."
HOMEPAGE="http://cafeconleche.org/XOM/index.html"
SRC_URI="http://cafeconleche.org/XOM/${XOMVER}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

COMMON_DEPEND=">=dev-java/xerces-2.7
		dev-java/xalan
		=dev-java/junit-3.8*
		dev-java/icu4j
		examples? ( =dev-java/servletapi-2.4* )
		dev-java/tagsoup"
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
	java-pkg_jar-from tagsoup
}

src_compile() {
	ant_flags="-Ddebug=off -Dtagsoup.jar=lib/tagsoup.jar"
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
