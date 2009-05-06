# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/eclipse-ecj/eclipse-ecj-3.3.0-r2.ebuild,v 1.7 2009/02/11 20:22:49 elvanor Exp $

inherit eutils java-pkg-2

MY_PN="ecj"
DMF="R-${PV}-200706251500"
S="${WORKDIR}"

DESCRIPTION="Eclipse Compiler for Java"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/${DMF/.0}/${MY_PN}src.zip"

LICENSE="EPL-1.0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
SLOT="3.3"
IUSE=""

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	sys-apps/findutils
	app-arch/unzip"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# own package
	rm -f org/eclipse/jdt/core/JDTCompilerAdapter.java
	rm -fr org/eclipse/jdt/internal/antadapter

	# what the heck...?! java6
	rm -fr org/eclipse/jdt/internal/compiler/tool/ \
		org/eclipse/jdt/internal/compiler/apt/

	# gcj feature
	epatch "${FILESDIR}"/${P}-gcj.patch
}

src_compile() {
	local javac="javac" java="java" jar="jar"

	mkdir -p bootstrap
	cp -pPR org bootstrap

	einfo "bootstrapping ${MY_PN} with javac"

	cd "${S}"/bootstrap
	${javac} $(find org/ -name '*.java') || die "${MY_PN} bootstrap failed!"

	find org/ -name '*.class' -o -name '*.properties' -o -name '*.rsc' | \
		xargs ${jar} cf ${MY_PN}.jar

	einfo "build ${MY_PN} with bootstrapped ${MY_PN}"

	cd "${S}"
	${java} -classpath bootstrap/${MY_PN}.jar \
		org.eclipse.jdt.internal.compiler.batch.Main -encoding ISO-8859-1 org \
		|| die "${MY_PN} build failed!"
	find org/ -name '*.class' -o -name '*.properties' -o -name '*.rsc' | \
		xargs ${jar} cf ${MY_PN}.jar
}

src_install() {
	java-pkg_dojar ${MY_PN}.jar
	java-pkg_dolauncher ${MY_PN}-${SLOT} --main \
		org.eclipse.jdt.internal.compiler.batch.Main
}

pkg_postinst() {
	ewarn "to get the compiler adapter of ecj for ant do"
	ewarn "	# emerge ant-eclipse-ecj"
}
