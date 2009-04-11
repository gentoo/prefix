# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-codec/commons-codec-1.3-r2.ebuild,v 1.4 2008/10/27 23:16:34 ranger Exp $

EAPI=1
JAVA_PKG_IUSE="doc source test"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Implementations of common encoders and decoders in Java."
HOMEPAGE="http://jakarta.apache.org/commons/codec/"
SRC_URI="mirror://apache/jakarta/commons/codec/source/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

RDEPEND=">=virtual/jre-1.4"

DEPEND=">=virtual/jdk-1.4
	test? ( dev-java/ant-junit:0 )
	${RDEPEND}"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/1.3-tests-fix.patch"
	sed -i "s_../LICENSE_LICENSE.txt_" build.xml  || die "sed failed"
	echo "conf.home=./src/conf" >> build.properties
	echo "source.home=./src/java" >> build.properties
	echo "build.home=./output" >> build.properties
	echo "dist.home=./output/dist" >> build.properties
	echo "test.home=./src/test" >> build.properties
	echo "final.name=commons-codec" >> build.properties
}

JAVA_ANT_ENCODING="ISO-8859-1"

src_install() {
	java-pkg_dojar output/dist/${PN}.jar

	dodoc RELEASE-NOTES.txt || die
	use doc && java-pkg_dojavadoc output/dist/docs/api
	use source && java-pkg_dosrc src/java/*
}
