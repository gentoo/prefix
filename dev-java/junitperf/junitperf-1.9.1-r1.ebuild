# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/junitperf/junitperf-1.9.1-r1.ebuild,v 1.9 2007/05/25 23:50:45 betelgeuse Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc test source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Simple framework to write repeatable tests"
SRC_URI="http://www.clarkware.com/software/${P}.zip"
HOMEPAGE="http://www.clarkware.com/software/JUnitPerf.html"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"

IUSE=""

RDEPEND=">=virtual/jre-1.3
	dev-java/junit"

DEPEND=">=virtual/jdk-1.3
	${RDEPEND}
	app-arch/unzip
	test? ( dev-java/ant-junit )"

src_unpack () {
	unpack ${A}
	rm "${S}"/lib/*.jar
	cd "${S}"/lib
	java-pkg_jar-from junit
}

EANT_DOC_TARGET=""

src_test() {
	ANT_TASKS="ant-junit" eant test
}

src_install() {
	java-pkg_dojar lib/${PN}.jar
	dodoc README || die
	use doc && java-pkg_dojavadoc docs/api
	use source && java-pkg_dosrc src/app/*
}
