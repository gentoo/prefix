# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xpp2/xpp2-2.1.10-r1.ebuild,v 1.12 2007/07/11 19:58:37 mr_bones_ Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

MY_PN="PullParser"
MY_P="${MY_PN}${PV}"
DESCRIPTION="A streaming pull XML parser used to quickly process input elements"
HOMEPAGE="http://www.extreme.indiana.edu/xgws/xsoap/xpp/mxp1/index.html"
SRC_URI="http://www.extreme.indiana.edu/xgws/xsoap/xpp/download/${MY_PN}2/${MY_P}.tgz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-fbsd ~x86-macos"
IUSE=""
S="${WORKDIR}/${MY_P}"

CDEPEND=">=dev-java/xerces-2.7"
DEPEND=">=virtual/jdk-1.3
	>=dev-java/ant-core-1.6
	${CDEPEND}"
RDEPEND=">=virtual/jre-1.3
	${CDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm lib/*/*.jar
	rm build/*/*.jar
	find build/ -name '*.jar' -o -name '*.class' -delete

	# add xercesImpl.jar to relevant javac classpaths
	xml-rewrite.py -f build.xml -e javac -a classpath -i 7 -c -v \
		'${build_intf}:lib/xercesImpl.jar' -i 7
	xml-rewrite.py -f build.xml -e javac -a classpath -i 8 -c -v \
		'${build_intf}:${build_impl_tag}:${build_x2impl_pp}:${build_impl_node}:${build_impl_format}:lib/xercesImpl.jar'

	cd lib
	java-pkg_jar-from xerces-2
}

src_compile() {
	# override check for xerces-2 presence
	eant -Dx2_present=true compile $(use_doc api)
}

src_install() {
	java-pkg_newjar build/lib/${MY_PN}-${PV}.jar ${MY_PN}.jar
	java-pkg_newjar build/lib/${MY_PN}-intf-${PV}.jar ${MY_PN}-intf.jar
	java-pkg_newjar build/lib/${MY_PN}-standard-${PV}.jar ${MY_PN}-standard.jar
	java-pkg_newjar build/lib/${MY_PN}-x2-${PV}.jar ${MY_PN}-x2.jar

	dohtml README.html
	use doc && java-pkg_dojavadoc doc/api
	use source && java-pkg_dosrc src/java/*
}
