# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/javacup/javacup-0.11a_beta20060608.ebuild,v 1.2 2007/07/11 19:58:37 mr_bones_ Exp $

EAPI="prefix"

JAVA_PKG_IUSE="source doc"
WANT_SPLIT_ANT="true"

inherit java-pkg-2 java-ant-2

DESCRIPTION="CUP Parser Generator for Java"

HOMEPAGE="http://www2.cs.tum.edu/projects/cup/"

# We cannot put the actual SRC_URI because it causes conflicts with Gentoo mirroring system
# No better URI is available, waiting until it hits actual Gentoo mirrors

#SRC_URI="https://www2.in.tum.de/WebSVN/dl.php?repname=CUP&path=/develop/&rev=0&isdir=1"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4
		>=dev-java/ant-core-1.7.0"

src_unpack() {
	unpack ${A}
	cd ${S}
	find . -name "*.class" -exec rm -f {} \;
	java-ant_rewrite-classpath
}

src_compile() {
	ANT_TASKS="none"
	eant -Dgentoo.classpath="$(java-pkg_getjars ant-core)"
	rm bin/java-cup-11.jar
	cp dist/java-cup-11a.jar bin/java-cup-11.jar
	eant clean
	einfo "Recompiling with newly generated javacup"
	eant -Dgentoo.classpath="$(java-pkg_getjars ant-core)"
	use doc && javadoc -sourcepath src/ java_cup -d javadoc
}

src_install() {
	java-pkg_newjar dist/java-cup-11a.jar
	java-pkg_newjar dist/java-cup-11a-runtime.jar ${PN}-runtime.jar
	java-pkg_register-ant-task

	dodoc changelog.txt || die
	dohtml manual.html || die
	use source && java-pkg_dosrc java/*
	use doc && java-pkg_dojavadoc javadoc
}
