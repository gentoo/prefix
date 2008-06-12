# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/log4j/log4j-1.2.14-r1.ebuild,v 1.7 2008/02/13 04:16:05 ali_bush Exp $

EAPI="prefix"

inherit java-pkg-2 java-ant-2

MY_P="logging-${P}"
DESCRIPTION="A low-overhead robust logging package for Java"
SRC_URI="mirror://apache/logging/log4j/${PV}/${MY_P}.tar.gz"
HOMEPAGE="http://logging.apache.org/log4j/"
LICENSE="Apache-1.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
# jikes support disabled: bug #108819
IUSE="doc javamail jms jmx source"

RDEPEND=">=virtual/jre-1.4
	javamail? ( dev-java/sun-javamail dev-java/sun-jaf )
	jmx? ( dev-java/sun-jmx )
	jms? ( =dev-java/openjms-bin-0.7.6 )"

# We should get log4j working with openjms but at the moment that would bring
# a circular dependency.
#	jms? ( || (=dev-java/openjms-0.7.6* =dev-java/openjms-bin-0.7.6* ))"

# Needs the a newer ant-core because otherwise source 1.1 and target 1.1 fails
# on at least blackdown-jdk-1.4.2.02. The other way to go around this is to
# explicitly set the javac.source and javac.target properties in the ebuild.

DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.6.5
	source? ( app-arch/zip )
	${RDEPEND}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd ${S}
	rm -rf dist/
	# Takes javamail from system env without this
	java-ant_xml-rewrite -f build.xml -c -e available -a ignoresystemclasses -v "true"
	java-pkg_filter-compiler jikes
}

src_compile() {
	# Because we depend on >=1.4 we always have jaxp
	local antflags="jar -Djaxp-present=true"
	use javamail && antflags="${antflags} -Djavamail.jar=$(java-pkg_getjar sun-javamail mail.jar) -Dactivation.jar=$(java-pkg_getjar sun-jaf activation.jar)"
	use jmx && antflags="${antflags} -Djmx.jar=$(java-pkg_getjar sun-jmx jmxri.jar) -Djmx-extra.jar=$(java-pkg_getjar sun-jmx jmxtools.jar)"
	#use jms && antflags="${antflags} -Djms.jar=$(java-pkg_getjar openjms jms.jar)"
	use jms && antflags="${antflags} -Djms.jar=/opt/openjms/lib/jms-1.0.2a.jar"
	eant ${antflags}
}

src_install() {
	java-pkg_newjar dist/lib/${P}.jar ${PN}.jar

	use doc && java-pkg_dohtml -r docs/*
	use source && java-pkg_dosrc src/java/*
}
