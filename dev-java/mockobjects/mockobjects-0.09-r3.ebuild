# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/mockobjects/mockobjects-0.09-r3.ebuild,v 1.1 2007/12/02 13:37:30 caster Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc examples source test"
inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Test-first development process for building object-oriented software"
HOMEPAGE="http://mockobjects.sf.net"
SRC_URI="http://dev.gentoo.org/~karltk/java/distfiles/mockobjects-java-${PV}-gentoo.tar.bz2"

LICENSE="Apache-1.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

CDEPEND="=dev-java/junit-3.8*"
# limiting to 1.4 jdk because there's some jdk-specific tests in build.xml that end with 1.4
# also there's bug #119080
# feel free to fix that and investigate workingness with 1.5+
DEPEND="${CDEPEND}
	|| ( =virtual/jdk-1.5* =virtual/jdk-1.4* )
	test? ( dev-java/ant-junit )"
RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

S="${WORKDIR}/mockobjects-java-${PV}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-gentoo.patch"
	epatch "${FILESDIR}/${P}-junit.patch"
	epatch "${FILESDIR}/${P}-java15.patch"

	mkdir -p out/jdk/classes || die

	cd lib || die
	java-pkg_jar-from junit
}

src_compile() {
	# ecj doesn't like subclassing PrintWriter in 1.5
	java-pkg_force-compiler javac
	java-pkg-2_src_compile
}

src_test() {
	# doesn't seem any tests get actually run, why?
	ANT_TASKS="ant-junit" eant junit
}

src_install() {
	java-pkg_newjar out/${PN}-alt-jdk1.4-${PV}.jar ${PN}-alt-jdk1.4.jar
	java-pkg_newjar out/${PN}-jdk1.4-${PV}.jar ${PN}-jdk1.4.jar
	java-pkg_newjar out/${PN}-core-${PV}.jar ${PN}-core.jar
	dodoc doc/README || die

	use doc && java-pkg_dojavadoc out/doc/javadoc
	use examples && java-pkg_doexamples src/examples
	use source && java-pkg_dosrc src/core/com src/extensions/com \
		src/jdk/common/com src/jdk/1.4/com
}
