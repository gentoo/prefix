# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/icu4j/icu4j-3.0-r1.ebuild,v 1.11 2008/03/17 21:40:31 betelgeuse Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="International Components for Unicode for Java"

HOMEPAGE="http://oss.software.ibm.com/icu4j/"
MY_PV=${PV/./_}
SRC_URI="ftp://www-126.ibm.com/pub/icu4j/${PV}/${PN}src_${MY_PV}.jar
		doc? ( ftp://www-126.ibm.com/pub/icu4j/${PV}/${PN}docs_${MY_PV}.jar )"
LICENSE="icu"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}

src_unpack() {
	jar -xf "${DISTDIR}/${PN}src_${MY_PV}.jar" || die "failed to unpack"
	if use doc; then
		mkdir docs; cd docs
		jar -xf "${DISTDIR}/${PN}docs_${MY_PV}.jar" || die "failed to unpack docs"
	fi
}

src_compile() {
	eant jar || die "compile failed"
}

src_install() {
	java-pkg_dojar ${PN}.jar

	use doc && java-pkg_dohtml -r readme.html docs/*
	use source && java-pkg_dosrc src/*
}
