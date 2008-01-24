# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/cglib/cglib-2.2_beta1.ebuild,v 1.5 2007/05/26 17:29:08 nelchael Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="cglib is a powerful, high performance and quality Code Generation Library."
SRC_URI="mirror://sourceforge/${PN}/${PN}-src-${PV}.jar"
HOMEPAGE="http://cglib.sourceforge.net"
LICENSE="Apache-1.1"
SLOT="2.2"
KEYWORDS="~amd64-linux ~x86-linux"
COMMON_DEP="=dev-java/asm-2.2*
	>=dev-java/ant-core-1.7.0"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/jarjar-0.9
	${COMMON_DEP}"
IUSE=""

S=${WORKDIR}

src_unpack() {
	jar xf "${DISTDIR}/${A}" || die "failed to unpack"

	cd "${S}/lib"
	rm -v *.jar || die
	java-pkg_jar-from asm-2.2 asm.jar
	java-pkg_jar-from asm-2.2 asm-util.jar
	java-pkg_jar-from asm-2.2 asm-commons.jar
	java-pkg_jar-from ant-core ant.jar
}

ANT_TASKS="jarjar-1"

src_install() {
	java-pkg_newjar dist/${P}.jar ${PN}.jar
	java-pkg_newjar dist/${PN}-nodep-${PV}.jar ${PN}-nodep.jar

	dodoc NOTICE README || die
	use doc && java-pkg_dohtml -r docs/*
}
