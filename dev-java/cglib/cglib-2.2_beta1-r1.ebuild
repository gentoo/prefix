# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/cglib/cglib-2.2_beta1-r1.ebuild,v 1.2 2008/03/30 17:14:43 corsair Exp $

EAPI=1
JAVA_PKG_IUSE="doc examples source"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="cglib is a powerful, high performance and quality Code Generation Library."
SRC_URI="mirror://sourceforge/${PN}/${PN}-src-${PV}.jar"
HOMEPAGE="http://cglib.sourceforge.net"
LICENSE="Apache-2.0"
SLOT="2.2"
KEYWORDS="~amd64-linux ~x86-linux"
COMMON_DEP="dev-java/asm:2.2
	>=dev-java/ant-core-1.7.0"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${COMMON_DEP}"
IUSE=""

S=${WORKDIR}

src_unpack() {
	unpack ${A}

	epatch "${FILESDIR}/2.2-nojarjar.patch"

	cd "${S}/lib"
	rm -v *.jar || die
	java-pkg_jar-from asm-2.2 asm.jar
	java-pkg_jar-from asm-2.2 asm-util.jar
	java-pkg_jar-from asm-2.2 asm-commons.jar
	java-pkg_jar-from ant-core ant.jar
}

# Fail giving a NullPointerException
RESTRICT="test"
EANT_TEST_JUNIT_INTO="lib"

src_install() {
	java-pkg_newjar dist/${P}.jar ${PN}.jar

	dodoc NOTICE README || die
	use doc && java-pkg_dojavadoc docs
	use source && java-pkg_dosrc src/proxy/net
	use examples && java-pkg_doexamples --subdir samples src/proxy/samples
}
