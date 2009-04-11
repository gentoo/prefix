# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xsd2jibx/xsd2jibx-0.2a_beta.ebuild,v 1.3 2007/05/26 17:21:32 nelchael Exp $

JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2

MY_PV="beta2a"

DESCRIPTION="JiBX binding and code from schema generator"
HOMEPAGE="http://jibx.sourceforge.net/xsd2jibx/"
SRC_URI="mirror://sourceforge/jibx/${PN}-${MY_PV}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

COMMON_DEP="dev-java/commons-logging
	dev-java/xpp3
	dev-java/ant-core
	dev-java/jaxme
	dev-java/jibx
	=dev-java/commons-lang-2.0*"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${COMMON_DEP}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	cp "${FILESDIR}/build.xml" .
	# patch from freemind authors, freemind won't build without it
	# they sent upstream (that's how I found it) which said he's preparing
	# complete rewrite. It only adds non-abstract functionality.
	epatch "${FILESDIR}/${P}-freemind.patch"

	cd "${S}/lib"
	rm -v *.jar
	java-pkg_jar-from commons-logging,xpp3,ant-core,jaxme,jibx,commons-lang
}

EANT_ANT_TASKS="jibx"
EANT_EXTRA_ARGS="-Djibxhome=${EPREFIX}/usr/share/jibx/"

src_install() {
	java-pkg_dojar lib/${PN}.jar

	dohtml -R docs/*
	use doc && java-pkg_dojavadoc api
	use source && java-pkg_dosrc src/main/org
}
