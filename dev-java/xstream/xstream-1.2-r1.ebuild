# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xstream/xstream-1.2-r1.ebuild,v 1.6 2008/04/27 20:03:49 maekke Exp $

JAVA_PKG_IUSE="doc examples java5 source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="A text-processing Java classes that serialize objects to XML and back again."
HOMEPAGE="http://xstream.codehaus.org/index.html"
SRC_URI="http://dist.codehaus.org/xstream/distributions/${P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

COMMON_DEPS="
	>=dev-java/commons-lang-2.1
	=dev-java/cglib-2.1*
	>=dev-java/dom4j-1.3
	dev-java/jsr173
	~dev-java/jdom-1.0
	=dev-java/jmock-1*
	>=dev-java/joda-time-1.2
	dev-java/xom
	>=dev-java/xpp3-1.1.3.4
	=dev-java/xml-commons-external-1.3*
"
#test? (
#		dev-java/ant-junit
#		dev-java/ant-trax
#		dev-java/xml-writer
#		dev-java/stax
#	)

DEPEND="java5? ( >=virtual/jdk-1.5 )
	!java5? ( =virtual/jdk-1.4* )
	app-arch/unzip
	${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPS}"

JAVA_PKG_BSFIX="off"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-javadoc-fix.patch"
	rm -v *.jar || die
	rm -v lib/jdk1.3/*.jar || die
	cd "${S}/lib"
	rm -v *.jar
	java-pkg_jar-from xml-commons-external-1.3
	java-pkg_jar-from jsr173
	java-pkg_jar-from cglib-2.1
	java-pkg_jar-from commons-lang-2.1
	java-pkg_jar-from dom4j-1
	java-pkg_jar-from jdom-1.0
	java-pkg_jar-from jmock-1.0
	java-pkg_jar-from joda-time
	java-pkg_jar-from xom
	java-pkg_jar-from xpp3
	java-pkg_filter-compiler jikes
}

# Restricted until we get keywords for deps. See:
# https://bugs.gentoo.org/show_bug.cgi?id=184234
RESTRICT="test"

src_test() {
	java-pkg_jar-from --into lib junit,xml-writer,stax
	ANT_TASKS="ant-junit ant-trax" eant test
}

src_install() {
	java-pkg_newjar ${P}.jar

	if use doc; then
		java-pkg_dojavadoc javadoc
	fi
	use source && java-pkg_dosrc src/java/com
}
