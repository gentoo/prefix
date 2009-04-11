# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jgroups/jgroups-2.4.1_p1-r2.ebuild,v 1.4 2008/10/25 17:13:56 nixnut Exp $

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

MY_PN="JGroups"
MY_PV="${PV/_p/-sp}"
MY_P="${MY_PN}-${MY_PV}"
DESCRIPTION="JGroups is a toolkit for reliable multicast communication."
SRC_URI="mirror://sourceforge/javagroups/${MY_P}.src.zip"
HOMEPAGE="http://www.jgroups.org/javagroupsnew/docs/"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
RDEPEND=">=virtual/jre-1.4
	dev-java/bsh
	dev-java/commons-logging
	dev-java/concurrent-util
	dev-java/sun-jms
	java-virtuals/jmx"

DEPEND=">=virtual/jdk-1.4
	${RDEPEND}
	app-arch/unzip"

S=${WORKDIR}/${MY_P}.src

src_unpack() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}/2.4.1-jdk4.patch"

	cd "${S}/lib" || die
	rm -v *.jar || die

	java-pkg_jar-from bsh
	java-pkg_jar-from commons-logging
	java-pkg_jar-from concurrent-util
	java-pkg_jar-from sun-jms
	java-pkg_jar-from --virtual jmx

	# Needed for unit tests
	#java-pkg_jar-from --build-only junit
	# One unit tests needs this
	#java-pkg_jar-from --build-only bcprov

	# Just get rid of these as they are of no use to us as we don't install them
	# Always tries to compile them. Does not build on 1.4 if we don't remove
	# these as they require java.lang.management
	rm -vr "${S}"/tests/{junit,other}/org || die
	java-pkg_filter-compiler jikes
}

JAVA_ANT_ENCODING="ISO-8859-1"

# The jar target generates jgroups-all.jar that has the demos and tests in it
EANT_BUILD_TARGET="jgroups-core.jar"

src_install() {
	java-pkg_dojar dist/jgroups-*.jar
	dodoc CREDITS README || die

	if use doc; then
		java-pkg_dojavadoc dist/javadoc
		insinto /usr/share/doc/${PF}
		doins -r doc/* || die
	fi
	use source && java-pkg_dosrc src/*

}

RESTRICT="test"
# A lot of these fail
src_test() {
	# run the report target for nice html pages
	ANT_TASKS="ant-junit" eant unittests-xml
}
