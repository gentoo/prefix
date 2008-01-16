# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-contrib/ant-contrib-1.0_beta2-r2.ebuild,v 1.7 2007/11/25 10:12:01 nelchael Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="The Ant-Contrib project is a collection of tasks (and at one point maybe types and other tools) for Apache Ant."
HOMEPAGE="http://ant-contrib.sourceforge.net/"
SRC_URI="mirror://sourceforge/ant-contrib/${PN}-${PV/_beta/b}-src.tar.bz2"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc source"

RDEPEND=">=virtual/jre-1.4
	>=dev-java/bcel-5.1
	>=dev-java/xerces-2.7
	>=dev-java/ant-core-1.7.0"
DEPEND=">=virtual/jdk-1.4
	${RDEPEND}"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}/lib"
	java-pkg_jar-from ant-core ant.jar
	java-pkg_jar-from bcel bcel.jar bcel-5.1.jar
	java-pkg_jar-from xerces-2
}

src_compile() {
	eant jar -Dversion=${PV} $(use_doc docs)
}

src_install() {
	java-pkg_dojar build/lib/${PN}.jar

	java-pkg_register-ant-task
	dodoc README.txt || die
	use doc && java-pkg_dojavadoc build/docs/api
	use source && java-pkg_dosrc src/net
	java-pkg_dohtml -r manual
}
