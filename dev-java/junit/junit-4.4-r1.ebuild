# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/junit/junit-4.4-r1.ebuild,v 1.5 2008/03/08 11:32:24 nelchael Exp $

EAPI="prefix"

# WARNING: JUNIT.JAR IS _NOT_ SYMLINKED TO ANT-CORE LIB FOLDER AS JUNIT3 IS

JAVA_PKG_IUSE="doc examples source test"

inherit java-pkg-2

MY_P=${P/-/}
DESCRIPTION="Simple framework to write repeatable tests"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"
HOMEPAGE="http://www.junit.org/"
LICENSE="CPL-1.0"
SLOT="4"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

CDEPEND="dev-java/hamcrest-core"
RDEPEND=">=virtual/jre-1.5
	${CDEPEND}"
DEPEND=">=virtual/jdk-1.5
	userland_GNU? ( >=sys-apps/findutils-4.3 )
	app-arch/unzip
	${CDEPEND}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	mkdir src || die
	unzip -qq -d src ${P}-src.jar || die "unzip failed"

	rm -rf javadoc temp.hamcrest.source *.jar || die
	find . -name "*.class" -delete || die
}

src_compile() {
	mkdir -p classes || die
	ejavac -d classes -cp $(java-pkg_getjars hamcrest-core) \
		$(find src -name "*.java")
	jar -cf ${PN}.jar -C classes . || die "jar failed"

	# generate javadoc
	if use doc ; then
		mkdir javadoc || die
		javadoc -d javadoc -sourcepath src -subpackages junit:org \
			-classpath $(java-pkg_getjars hamcrest-core) || die "javadoc failed"
	fi
}

src_test() {
	ejavac -sourcepath org:junit -classpath $(java-pkg_getjars hamcrest-core):${PN}.jar \
		-d classes $(find org junit -name "*.java")
	cd classes
	for FILE in $(find . -name "AllTests\.class"); do
		if [[ ${FILE} != "./org/junit/runners/AllTests.class" ]] ; then
			local CLASS=$(echo ${FILE} | sed -e "s/\.class//" | sed -e "s%/%.%g" | sed -e "s/\.\.//")
			java -classpath .:$(java-pkg_getjars hamcrest-core) \
				org.junit.runner.JUnitCore ${CLASS} || die "Test ${CLASS} failed"
		fi
	done
}

src_install() {
	java-pkg_dojar ${PN}.jar
	dodoc README.html doc/ReleaseNotes${PV}.txt || die

	if use doc; then
		dohtml -r doc/*
		java-pkg_dojavadoc javadoc
	fi

	if use examples; then
		java-pkg_doexamples org
	fi

	use source && java-pkg_dosrc src/org src/junit
}
