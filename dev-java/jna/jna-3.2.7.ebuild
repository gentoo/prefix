# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jna/jna-3.2.7.ebuild,v 1.1 2011/01/25 17:47:14 fordfrog Exp $

EAPI="4"

JAVA_PKG_IUSE="test doc source"
WANT_ANT_TASKS="ant-nodeps"

inherit java-pkg-2 java-ant-2 toolchain-funcs flag-o-matic multilib

DESCRIPTION="Java Native Access (JNA)"
HOMEPAGE="https://jna.dev.java.net/"
SRC_URI="https://jna.dev.java.net/source/browse/*checkout*/jna/tags/${PV}/jnalib/dist/src.zip -> ${P}-src.zip
	https://jna.dev.java.net/source/browse/*checkout*/jna/tags/${PV}/jnalib/contrib/platform/build.xml -> ${P}-platform-build.xml
	https://jna.dev.java.net/source/browse/*checkout*/jna/tags/${PV}/jnalib/contrib/platform/nbproject/build-impl.xml -> ${P}-platform-build-impl.xml
	https://jna.dev.java.net/source/browse/*checkout*/jna/tags/${PV}/jnalib/contrib/platform/nbproject/project.properties?rev=1138 -> ${P}-platform-project.properties"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""
S="${WORKDIR}"

RDEPEND="virtual/libffi
	>=virtual/jre-1.6"

DEPEND="virtual/libffi
	>=virtual/jdk-1.6
	test? (
		dev-java/junit:0
		dev-java/ant-junit:0
		dev-java/ant-trax:0
	)"

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_BUILD_TARGET="jar contrib-jars"

src_unpack() {
	unpack ${P}-src.zip
	mkdir -p contrib/platform/nbproject || die
	cp "${DISTDIR}"/${P}-platform-build.xml contrib/platform/build.xml || die
	cp "${DISTDIR}"/${P}-platform-build-impl.xml contrib/platform/nbproject/build-impl.xml || die
	cp "${DISTDIR}"/${P}-platform-project.properties contrib/platform/nbproject/project.properties || die
}

java_prepare() {
	# respect CFLAGS, don't inhibit warnings, honour CC
	# fix build.xml file
	epatch "${FILESDIR}/${PV}-makefile-flags.patch" "${FILESDIR}/${PV}-build.xml.patch"

	# ... and also on Solaris platforms
	sed -i -e '150,$s/SunOS/SunOSWithoutPrefix/g' build.xml || die
	# ... and Darwin
	sed -i -e 's:/Developer:/no-way/dont/do/this:g' build.xml || die

	# Fetch our own prebuilt libffi.
	mkdir -p build/native/libffi/.libs || die
	ln -snf "${EPREFIX}/usr/$(get_libdir)/libffi$(get_libname)" \
		build/native/libffi/.libs/libffi_convenience.a || die

	# Build to same directory on 64-bit archs.
	ln -snf build build-d64 || die
}

EANT_EXTRA_ARGS="-Ddynlink.native=true"

src_install() {
	java-pkg_dojar build/${PN}.jar
	java-pkg_dojar contrib/platform/dist/platform.jar
	java-pkg_doso build/native/libjnidispatch.so # this will break on osx
	use source && java-pkg_dosrc src/com
	use doc && java-pkg_dojavadoc doc/javadoc
}

src_test() {
	unset DISPLAY

	mkdir -p lib
	java-pkg_jar-from --into lib --build-only junit

	ANT_TASKS="ant-junit ant-nodeps ant-trax" \
		ANT_OPTS="-Djava.awt.headless=true" eant \
		${EANT_EXTRA_ARGS} test
}
