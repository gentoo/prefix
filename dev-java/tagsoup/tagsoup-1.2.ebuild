# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/tagsoup/tagsoup-1.2.ebuild,v 1.5 2008/03/11 15:10:07 ranger Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"
WANT_ANT_TASKS="ant-trax"

inherit java-pkg-2 java-ant-2

DESCRIPTION="A SAX-compliant parser written in Java."

HOMEPAGE="http://mercury.ccil.org/~cowan/XML/tagsoup/"
SRC_URI="http://mercury.ccil.org/~cowan/XML/tagsoup/${P}-src.zip"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip"
RDEPEND=">=virtual/jre-1.4"

EANT_BUILD_TARGET="dist"
EANT_DOC_TARGET="docs-api"

src_install() {
	java-pkg_newjar dist/lib/${P}.jar ${PN}.jar
	java-pkg_dolauncher ${PN} --jar ${PN}.jar

	# Has Main-Class and no deps
	java-pkg_dolauncher

	doman ${PN}.1 || die
	dodoc CHANGES README TODO || die

	use doc && java-pkg_dojavadoc docs/api
	use source && java-pkg_dosrc src/{java,templates}/*
}
