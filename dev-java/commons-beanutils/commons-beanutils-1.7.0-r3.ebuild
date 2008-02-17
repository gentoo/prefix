# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-beanutils/commons-beanutils-1.7.0-r3.ebuild,v 1.1 2008/02/13 18:07:26 betelgeuse Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Provides easy-to-use wrappers around Reflection and Introspection APIs"
HOMEPAGE="http://jakarta.apache.org/commons/beanutils/"
SRC_URI="mirror://apache/jakarta/commons/beanutils/source/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="1.7"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE=""

COMMON_DEP="
	>=dev-java/commons-collections-2.1
	>=dev-java/commons-logging-1.0.2"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	${COMMON_DEP}"

S="${WORKDIR}/${P}-src"

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -vr src/java/org/apache/commons/collections/ || die
	java-ant_rewrite-classpath
}

EANT_GENTOO_CLASSPATH="commons-logging,commons-collections"

src_install() {
	java-pkg_dojar dist/${PN}*.jar

	dodoc RELEASE-NOTES.txt || die
	dohtml STATUS.html PROPOSAL.html || die

	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/*
}
