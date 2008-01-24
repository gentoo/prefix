# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/cglib/cglib-2.0.2-r2.ebuild,v 1.10 2007/04/26 20:12:33 betelgeuse Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"
inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="A powerful, high performance and quality Code Generation Library."
SRC_URI="mirror://sourceforge/${PN}/${PN}-src-${PV}.jar"
HOMEPAGE="http://cglib.sourceforge.net"
LICENSE="Apache-1.1"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux"
COMMON_DEP="=dev-java/asm-1.4.3*
	=dev-java/aspectwerkz-2*
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	${COMMON_DEP}"
IUSE=""

S=${WORKDIR}

src_unpack() {
	jar xf ${DISTDIR}/${A} || die "failed to unpack"

	epatch "${FILESDIR}/${P}-asm-1.4.3.patch"

	cd "${S}/lib"
	rm -v *.jar || die
	java-pkg_jar-from asm-1.4
	java-pkg_jar-from aspectwerkz-2
	java-pkg_jar-from ant-core ant.jar
}

src_install() {
	java-pkg_newjar dist/${PN}-${PV}.jar
	java-pkg_newjar dist/${PN}-full-${PV}.jar ${PN}-full.jar

	dodoc NOTICE README || die
	use doc && java-pkg_dojavadoc docs
	use source && java-pkg_dosrc src/proxy/net
}
