# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/log4j/log4j-1.2.15-r2.ebuild,v 1.8 2010/01/23 13:27:51 aballier Exp $

EAPI=2
JAVA_PKG_IUSE="doc javamail jms jmx source"

inherit java-pkg-2 java-ant-2

MY_P="apache-${P}"
DESCRIPTION="A low-overhead robust logging package for Java"
SRC_URI="mirror://apache/logging/${PN}/${PV}/${MY_P}.tar.gz"
HOMEPAGE="http://logging.apache.org/log4j/"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris"
# jikes support disabled: bug #108819
IUSE="doc javamail jms jmx source"

CDEPEND="javamail? ( java-virtuals/javamail java-virtuals/jaf )
		jmx? ( dev-java/sun-jmx:0 )
		jms? ( java-virtuals/jms )"

RDEPEND=">=virtual/jre-1.4
		${CDEPEND}"

DEPEND=">=virtual/jdk-1.4
		${CDEPEND}"

S="${WORKDIR}/${MY_P}"

java_prepare() {
	rm -rf dist/
	java-pkg_filter-compiler jikes
	rm -v *.jar || die
}

JAVA_ANT_REWRITE_CLASSPATH="true"
JAVA_ANT_IGNORE_SYSTEM_CLASSES="true"
EANT_EXTRA_ARGS="-Djaxp-present=true"
EANT_DOC_TARGET=""

src_compile() {
	if use javamail; then
		EANT_GENTOO_CLASSPATH+="javamail,jaf"
		EANT_EXTRA_ARGS+=" -Djavamail-present=true"
	fi
	if use jmx; then
		use javamail && EANT_GENTOO_CLASSPATH+=","
		EANT_GENTOO_CLASSPATH+="sun-jmx"
		EANT_EXTRA_ARGS+=" -Djmx-present=true"
	fi
	if use jms; then
		EANT_EXTRA_ARGS+=" -Djms-present=true -Djms.jar=$(java-pkg_getjars jms)"
	fi
	java-pkg-2_src_compile
}

src_install() {
	java-pkg_newjar dist/lib/${P}.jar ${PN}.jar

	if use doc ; then
		java-pkg_dohtml -r site/*
		rm -fr "${ED}/usr/share/doc/${PF}/html/apidocs"
		java-pkg_dojavadoc --symlink apidocs site/apidocs
	fi
	use source && java-pkg_dosrc src/main/java/*
}
