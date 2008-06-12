# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/icu4j/icu4j-3.6.1-r1.ebuild,v 1.3 2008/03/17 21:40:31 betelgeuse Exp $

EAPI="prefix"

# We currently download the Javadoc documentation.
# It could optionally be built using the Ant build file.
# testdata.jar and icudata.jar do not contain *.class files but *.res files
# These *.res data files are needed to built the final jar
# They do not need to be installed however as they will already be present in icu4j.jar

JAVA_PKG_IUSE="source"

inherit java-pkg-2 java-ant-2 java-osgi

DESCRIPTION="ICU4J is a set of Java libraries providing Unicode and Globalization support."
MY_PV=${PV//./_}

SRC_URI="http://download.icu-project.org/files/${PN}/${PV}/${PN}src_${MY_PV}.jar
	doc? ( http://download.icu-project.org/files/${PN}/${PV}/${PN}docs_${MY_PV}.jar )"

HOMEPAGE="http://www.icu-project.org/"
LICENSE="icu"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"

RDEPEND=">=virtual/jre-1.4"

DEPEND="test? ( || ( =virtual/jdk-1.5* =virtual/jdk-1.4* ) )
	!test? ( >=virtual/jdk-1.4 )
	app-arch/unzip"

IUSE="doc test"

S="${WORKDIR}"

src_unpack() {
	jar -xf "${DISTDIR}/${PN}src_${MY_PV}.jar" || die "Failed to unpack"

	if use doc; then
		mkdir docs; cd docs
		jar -xf "${DISTDIR}/${PN}docs_${MY_PV}.jar" || die "Failed to unpack docs"
	fi
}

src_compile() {
	# Classes extending CharsetICU not implementing Comparable
	# Breaks with ecj on jdk 1.5+, javac doesn't mind - Sun's hack?
	# Restricting to javac (didn't even care to try jikes) is better
	# than forcing 1.4
	java-pkg_force-compiler javac
	eant jar || die "Compile failed"
}

src_install() {
	java-osgi_newjar-fromfile "${PN}.jar" "${FILESDIR}/icu4j-${PV}-manifest" \
		"International Components for Unicode for Java (ICU4J)"
	java-pkg_dojar "${PN}-charsets.jar"

	use doc && dohtml -r readme.html docs/*
	use source && java-pkg_dosrc src/*
}

# Following tests will fail in Sun JDK 6 (at least):
# toUnicode: http://bugs.icu-project.org/trac/ticket/5663
# TimeZoneTransitionAdd: http://bugs.icu-project.org/trac/ticket/5887
# These are bugs in the tests themselves, not in the library

src_test() {
	eant check
}
