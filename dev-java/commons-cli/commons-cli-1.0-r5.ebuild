# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-cli/commons-cli-1.0-r5.ebuild,v 1.13 2007/08/03 15:30:33 betelgeuse Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source test"

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="The CLI library provides a simple and easy to use API for working with the command line arguments and options."
HOMEPAGE="http://jakarta.apache.org/commons/cli/"
SRC_URI="mirror://apache/jakarta/commons/cli/source/cli-${PV}-src.tar.gz"

LICENSE="Apache-1.1"
SLOT="1"
KEYWORDS="~amd64 ~x86 ~x86-fbsd ~x86-macos"
IUSE=""

CDEPEND="dev-java/commons-logging
	=dev-java/commons-lang-2.0*"
RDEPEND=">=virtual/jre-1.4
	${CDEPEND}"
DEPEND=">=virtual/jdk-1.4
	test? ( dev-java/ant-junit )
	${CDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-build.xml.patch"

	mkdir lib && cd lib
	java-pkg_jar-from commons-logging commons-logging.jar
	java-pkg_jar-from commons-lang
}

src_test() {
	java-pkg_jar-from --into lib junit
	ANT_TASKS="ant-junit" eant test
}

src_install() {
	java-pkg_newjar target/${P}.jar

	dodoc README.txt || die
	use doc && java-pkg_dojavadoc target/docs/apidocs
	use source && java-pkg_dosrc src/java/org
}
