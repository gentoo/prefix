# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/aspectwerkz/aspectwerkz-2.0_rc2-r2.ebuild,v 1.12 2008/03/30 17:12:41 corsair Exp $

JAVA_PKG_BSFIX="off"
# no rewriting required since we patch build.xml to contain target/source

inherit java-pkg-2 eutils java-ant-2

DESCRIPTION="AspectWerkz is a dynamic, lightweight and high-performant AOP/AOSD framework for Java."
SRC_URI="http://dist.codehaus.org/${PN}/distributions/${P/_rc/.RC}.zip"
HOMEPAGE="http://aspectwerkz.codehaus.org"
LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux"
RDEPEND=">=virtual/jre-1.3
	=dev-java/asm-1.5*
	dev-java/bcel
	dev-java/concurrent-util
	=dev-java/dom4j-1*
	=dev-java/javassist-2*
	dev-java/jrexx
	=dev-java/junit-3.8*
	>=dev-java/junitperf-1.9.1
	dev-java/trove
	dev-java/qdox"
DEPEND="java5? ( >=virtual/jdk-1.5 )
	!java5? ( >=virtual/jdk-1.3 )
	>=dev-java/java-config-2.0.31
	${RDEPEND}
	>=dev-java/ant-core-1.5
	app-arch/unzip
	source? ( app-arch/zip )"
IUSE="java5 source"

S=${WORKDIR}/aw_2_0_2

# These fail
RESTRICT="test"

src_unpack() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}"/${P}-gentoo.patch
	epatch "${FILESDIR}"/${P}-jdk15.patch

	find . -name '*.jar' -exec rm {} \; || die
	cd "${S}"/lib
	#rm *.jar
	java-pkg_jar-from asm-1.5
	java-pkg_jar-from bcel
	java-pkg_jar-from concurrent-util
	java-pkg_jar-from dom4j-1
	java-pkg_jar-from javassist-2
	java-pkg_jar-from jrexx
	java-pkg_jar-from junit
	java-pkg_jar-from junitperf
	java-pkg_jar-from trove
	java-pkg_jar-from qdox-1.6
}

src_compile() {
	local antflags
	use "!java5" && antflags="-Dnojdk15=true"
	eant ${antflags} dist || die "eant failed"
}

src_install() {
	java-pkg_dojar lib/${PN}*.jar

	use source && java-pkg_dosrc src/*
}
