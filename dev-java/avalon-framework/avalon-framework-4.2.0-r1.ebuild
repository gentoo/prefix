# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/avalon-framework/avalon-framework-4.2.0-r1.ebuild,v 1.10 2007/06/12 16:04:54 flameeyes Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Avalon Framework"
HOMEPAGE="http://avalon.apache.org/"
SRC_URI="mirror://apache/avalon/avalon-framework/source/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="4.2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

COMMON_DEP="=dev-java/avalon-logkit-2*
	>=dev-java/log4j-1.2.9"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	${COMMON_DEP}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	cp "${FILESDIR}/build.xml" ./build.xml || die "ANT update failure!"
	local libs="log4j,avalon-logkit-2.0"
	echo "classpath=$(java-pkg_getjars ${libs})" > build.properties
}

src_install() {
	java-pkg_dojar ${S}/dist/avalon-framework.jar

	dodoc NOTICE.TXT || die
	use doc && java-pkg_dojavadoc target/docs
	use source && java-pkg_dosrc impl/src/java/*
}
