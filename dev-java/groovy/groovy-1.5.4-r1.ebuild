# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/groovy/groovy-1.5.4-r1.ebuild,v 1.2 2009/03/29 16:40:07 betelgeuse Exp $

# Groovy's build system is Ant based, but they use Maven for fetching the dependencies.
# We just have to remove the fetch dependencies target, and then we can use Ant for this ebuild.
#
# Note that in the previous 1.0 ebuild, we used the Ant Maven plugin. We don't do that anymore.

# We currently do not build the embeddable jar (which is created using JarJar). Maybe we should...
# We also don't use automatic build rewriting as there seems to be already some level of support
# in the upstream build system
#

# TODO: We should implement the doc USE flag properly
#

EAPI=2
WANT_ANT_TASKS="ant-antlr ant-trax"

inherit versionator java-pkg-2 java-ant-2

JAVA_PKG_IUSE="doc"
MY_PV=${PV/_rc/-RC-}
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Groovy is a high-level dynamic language for the JVM"
HOMEPAGE="http://groovy.codehaus.org/"

SRC_URI="http://dist.groovy.codehaus.org/distributions/${PN}-src-${PV}.zip"
LICENSE="codehaus-groovy"
SLOT="1"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="test"

CDEPEND="
	dev-java/asm:2.2
	>=dev-java/antlr-2.7.7:0[java]
	>=dev-java/xstream-1.1.1
	>=dev-java/junit-3.8.2:0
	>=dev-java/jline-0.9.91
	>=dev-java/ant-core-1.7.0
	>=dev-java/commons-cli-1.0
	>=dev-java/mockobjects-0.09
	~dev-java/servletapi-2.4
	=dev-java/mx4j-core-3.0*
	>=dev-java/bsf-2.4
	java-virtuals/jmx

	test? (
		dev-java/jmock
		dev-java/xmlunit
		dev-db/hsqldb
		dev-java/ant-junit
	)

	dev-java/qdox
	"

RDEPEND=">=virtual/jre-1.4
	${CDEPEND}"

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${CDEPEND}"

S="${WORKDIR}/${MY_P}"

JAVA_PKG_BSFIX=""

java_prepare() {
	epatch "${FILESDIR}/${PN}-build.xml.patch"
	java-ant_xml-rewrite -f build.xml --delete -e junit -a fork

	rm -rf bootstrap
	rm -rf security

	mkdir -p target/lib && cd target/lib

	mkdir compile && mkdir runtime && mkdir tools

	cd compile

	java-pkg_jar-from commons-cli-1
	java-pkg_jar-from ant-core
	java-pkg_jar-from antlr
	java-pkg_jar-from asm-2.2
	java-pkg_jar-from xstream
	java-pkg_jar-from mockobjects
	java-pkg_jar-from jline
	java-pkg_jar-from junit
	java-pkg_jar-from servletapi-2.4
	java-pkg_jar-from bsf-2.3
	java-pkg_jar-from --virtual jmx

	# Following is for documentation only

	java-pkg_jar-from qdox-1.6
}

src_compile() {
	eant -DskipTests="true" -DruntimeLibDirectory="target/lib/compile" \
		-DtoolsLibDirectory="target/lib/compile" createJars

	# This works

	#ANT_TASKS="none" eant -Dno.grammars -DruntimeLibDirectory="target/lib/compile" \
	# -DtoolsLibDirectory="target/lib/compile" doc
	#use doc && eant doc
}

src_test() {
	cd "${S}/target/lib" && mkdir test && cd compile

	java-pkg_jar-from jmock-1.0
	java-pkg_jar-from xmlunit-1
	java-pkg_jar-from hsqldb

	cd "${S}"
	ANT_TASKS="ant-junit ant-antlr ant-trax" eant test -DruntimeLibDirectory="target/lib/compile" \
		-DtestLibDirectory="target/lib/compile"
}

src_install() {
	java-pkg_newjar "target/dist/${P}.jar"
	java-pkg_dolauncher "groovyc" --main org.codehaus.groovy.tools.FileSystemCompiler
	java-pkg_dolauncher "groovy" --main groovy.ui.GroovyMain
	java-pkg_dolauncher "groovysh" --main groovy.ui.InteractiveShell
	java-pkg_dolauncher "groovyConsole" --main groovy.ui.Console

	# java-pkg_dolauncher "grok" --main org.codehaus.groovy.tools.Grok Grok does not exist anymore
}
