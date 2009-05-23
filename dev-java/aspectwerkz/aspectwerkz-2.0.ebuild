# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/aspectwerkz/aspectwerkz-2.0.ebuild,v 1.3 2009/05/20 16:03:46 caster Exp $

EAPI=2

JAVA_PKG_IUSE="doc java5 source"

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="AspectWerkz is a dynamic, lightweight and high-performant AOP/AOSD framework for Java."
SRC_URI="http://dist.codehaus.org/${PN}/distributions/${P}.zip"
HOMEPAGE="http://aspectwerkz.codehaus.org"
LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
# bug 203268
RESTRICT="test"

COMMON_DEP="
	dev-java/asm:1.5
	dev-java/concurrent-util:0
	dev-java/dom4j:1
	dev-java/jrexx:0
	dev-java/trove:0
	dev-java/qdox:1.6
	dev-java/junit:0"
RDEPEND="
	!java5? ( >=virtual/jre-1.4 )
	java5? ( >=virtual/jre-1.5 )
	${COMMON_DEP}"
DEPEND="
	!java5? ( >=virtual/jdk-1.4 )
	java5? ( >=virtual/jdk-1.5 )
	${COMMON_DEP}
	app-arch/unzip"

java_prepare() {
	# unit tests need this
	chmod +x "bin/${PN}" || die
	epatch "${FILESDIR}/${P}-gentoo.patch"

	find . -name '*.jar' -delete || die

	cd "${S}/lib"
	java-pkg_jar-from asm-1.5
	java-pkg_jar-from concurrent-util
	java-pkg_jar-from dom4j-1
	java-pkg_jar-from jrexx
	java-pkg_jar-from junit
	java-pkg_jar-from trove
	java-pkg_jar-from qdox-1.6
}

_eant() {
	local antflags
	use java5 && antflags="-Djava.version=1.5" || antflags="-Djava.version=1.4"
	eant ${antflags} "${@}"

}

src_compile() {
	_eant dist #precompiled javadocs
}

src_test() {
	_eant test
}

src_install() {
	use source && java-pkg_dosrc src/*
	# other stuff besides javadoc here too
	use doc && java-pkg_dohtml -r docs/*

	cd lib
	for jar in ${PN}*.jar; do
		java-pkg_newjar ${jar} ${jar/-${PV}}
	done
}
