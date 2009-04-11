# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/scala/scala-2.6.0.ebuild,v 1.1 2007/12/17 17:48:13 caleb Exp $

JAVA_PKG_IUSE="doc examples source"
WANT_ANT_TASKS="ant-nodeps"
inherit check-reqs java-pkg-2 java-ant-2 versionator

MY_P="${P}-final"

DESCRIPTION="The Scala Programming Language"
HOMEPAGE="http://www.scala-lang.org/"
SRC_URI="http://www.scala-lang.org/downloads/distrib/files/${MY_P}-sources.tgz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
DEPEND=">=virtual/jdk-1.5
	dev-java/ant-contrib"
RDEPEND=">=virtual/jre-1.5"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	java-pkg-2_pkg_setup

	debug-print "Checking for sufficient physical RAM"

	# this is needed with apple-jdk-bin:1.6 at least, because it's 64bit
	# apple-jdk-bin:1.[45] might work with 512MB
	if use amd64 || use x86-macos; then
		CHECKREQS_MEMORY="1024"
	else
		CHECKREQS_MEMORY="512"
	fi
	check_reqs
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# remove check for ant-nodeps.jar in ant-core/lib; make docs opt-in;
	# don't increase version; don't create dist archives
	epatch "${FILESDIR}/${P}-build.xml.patch"

	cd lib || die
	# other jars are needed for bootstrap
	rm -v ant-contrib.jar || die
	java-pkg_jar-from --build-only ant-contrib
}

src_compile() {
	# this is needed with apple-jdk-bin:1.6 at least, because it's 64bit
	# apple-jdk-bin:1.[45] might work with 512MB
	if use amd64 || use x86-macos; then
		export ANT_OPTS="-Xmx1024M -Xms1024M"
	else
		export ANT_OPTS="-Xmx512M -Xms512M -Xss1024k"
	fi
	local target
	if [[ "$(get_version_component_range 3)"  == "0" ]];
	then
		target="minor"
	else
		target="patch"
	fi
	eant dist.${target} $(use_doc -Ddo.docs=true)
}

src_test() {
	bash ${S}/test/scalatest || die "Some tests aren't passed"
}

scala_launcher() {
	local SCALADIR="/usr/share/${PN}"
	local bcp="${SCALADIR}/lib/scala-library.jar"
	java-pkg_dolauncher "${1}" --main "${2}" ${3} \
		--java_args "-Xmx256M -Xms16M -Xbootclasspath/a:\\\"${EPREFIX}${bcp}\\\" -Dscala.home=\\\"${EPREFIX}${SCALADIR}\\\" -Denv.classpath=\\\"\${CLASSPATH}\\\""
}

src_install() {
	cd dists/${MY_P} || die
	local SCALADIR="/usr/share/${PN}/"

	# sources are .scala so no use for java-pkg_dosrc
	if use source; then
		dodir "${SCALADIR}/src"
		insinto "${SCALADIR}/src"
		doins lib/*-src.jar
	fi

	rm lib/*-src.jar
	java-pkg_dojar lib/*.jar

	doman man/man1/*.1 || die
	local docdir="doc/${PN}"
	dodoc "${docdir}"/{LICENSE,README} ../../docs/TODO || die
	if use doc; then
		java-pkg_dojavadoc "${docdir}/api"
		dohtml -r "${docdir}/tools" || die
	fi
	use examples && java-pkg_doexamples "${docdir}/examples"

	scala_launcher fsc scala.tools.nsc.CompileClient
	scala_launcher scala scala.tools.nsc.MainGenericRunner
	scala_launcher scalac scala.tools.nsc.Main
	scala_launcher scaladoc scala.tools.nsc.Main "--pkg_args -doc"
}
