# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jibx/jibx-1.1.3.ebuild,v 1.4 2007/05/15 10:57:45 ali_bush Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2 versionator

MY_PV=$(replace_all_version_separators '_')

DESCRIPTION="JiBX: Binding XML to Java Code"
HOMEPAGE="http://jibx.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}_${MY_PV}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

COMMON_DEP="=dev-java/dom4j-1*
	dev-java/ant-core
	dev-java/bcel
	dev-java/jsr173
	dev-java/xpp3"

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${COMMON_DEP}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S="${WORKDIR}/${PN}"

src_unpack() {

	unpack ${A}

	cd "${S}/lib"
	rm -f *.jar

	java-pkg_jarfrom ant-core
	java-pkg_jarfrom bcel
	java-pkg_jarfrom dom4j-1
	java-pkg_jarfrom jsr173
	java-pkg_jarfrom xpp3

}

EANT_BUILD_XML="build/build.xml"
EANT_BUILD_TARGET="small-jars"

src_install() {

	cd "${S}/lib/"
	java-pkg_dojar "${S}/lib"/jibx-bind.jar
	java-pkg_dojar "${S}/lib"/jibx-extras.jar
	java-pkg_dojar "${S}/lib"/jibx-run.jar

	cd "${S}"
	dodoc changes.txt readme.html docs/binding.dtd docs/binding.xsd

	use doc && {
		java-pkg_dohtml -r docs/*
		cp -R starter "${ED}/usr/share/doc/${PF}"
		cp -R tutorial "${ED}/usr/share/doc/${PF}"
	}

	use source && java-pkg_dosrc ${S}/build/src/* ${S}/build/extras/*

}
