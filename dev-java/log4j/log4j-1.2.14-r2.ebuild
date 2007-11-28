# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/log4j/log4j-1.2.14-r2.ebuild,v 1.3 2007/11/28 07:35:56 ali_bush Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc javamail jms jmx source"

inherit java-pkg-2 java-ant-2

MY_P="logging-${P}"
DESCRIPTION="A low-overhead robust logging package for Java"
SRC_URI="mirror://apache/logging/log4j/${PV}/${MY_P}.tar.gz"
HOMEPAGE="http://logging.apache.org/log4j/"
LICENSE="Apache-1.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos"
# jikes support disabled: bug #108819
IUSE="doc javamail jms jmx source"

CDEPEND="javamail? ( java-virtuals/javamail dev-java/sun-jaf )
		jmx? ( dev-java/sun-jmx )
		jms? ( =dev-java/openjms-bin-0.7.6 )"

RDEPEND=">=virtual/jre-1.4
		${CDEPEND}"

# We should get log4j working with openjms but at the moment that would bring
# a circular dependency.
#	jms? ( || (=dev-java/openjms-0.7.6* =dev-java/openjms-bin-0.7.6* ))"

# Needs the a newer ant-core because otherwise source 1.1 and target 1.1 fails
# on at least blackdown-jdk-1.4.2.02. The other way to go around this is to
# explicitly set the javac.source and javac.target properties in the ebuild.

DEPEND=">=virtual/jdk-1.4
		>=dev-java/ant-core-1.6.5
		${CDEPEND}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -rf dist/
	# Takes javamail from system env without this
	xml-rewrite.py -f build.xml -c -e available -a ignoresystemclasses -v "true"
	java-pkg_filter-compiler jikes
}

src_compile() {
	# Because we depend on >=1.4 we always have jaxp
	local antflags="jar -Djaxp-present=true"
	use javamail && antflags="${antflags} -Djavamail.jar=$(java-pkg_getjar javamail mail.jar) -Dactivation.jar=$(java-pkg_getjar sun-jaf activation.jar)"
	use jmx && antflags="${antflags} -Djmx.jar=$(java-pkg_getjar sun-jmx jmxri.jar) -Djmx-extra.jar=$(java-pkg_getjar sun-jmx jmxtools.jar)"
	#use jms && antflags="${antflags} -Djms.jar=$(java-pkg_getjar openjms jms.jar)"
	use jms && antflags="${antflags} -Djms.jar=/opt/openjms/lib/jms-1.0.2a.jar"
	eant ${antflags}
}

src_install() {
	java-pkg_newjar dist/lib/${P}.jar ${PN}.jar

	use doc && dohtml -r docs/*
	use source && java-pkg_dosrc src/java/*
}
