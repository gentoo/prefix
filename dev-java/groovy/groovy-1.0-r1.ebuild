# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/groovy/groovy-1.0-r1.ebuild,v 1.4 2007/07/04 22:14:28 betelgeuse Exp $

EAPI="prefix"

inherit versionator java-pkg-2 java-ant-2

MY_PV=${PV/_rc/-RC-}
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Groovy is a high-level dynamic language for the JVM"
HOMEPAGE="http://groovy.codehaus.org/"
SRC_URI="http://dist.codehaus.org/groovy/distributions/${MY_P/JSR/jsr}-src.tar.gz"
LICENSE="codehaus-groovy"
SLOT="1"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="bsf"
# testcases won't even compile in current state
#RESTRICT="test"

COMMON_DEPS="
	=dev-java/asm-2.2*
	>=dev-java/antlr-2.7.5
	>=dev-java/xerces-2.7
	>=dev-java/ant-core-1.6.5
	>=dev-java/xstream-1.1.1
	=dev-java/junit-3*
	dev-java/qdox
	>=dev-java/commons-cli-1.0
	>=dev-java/mockobjects-0.09
	~dev-java/servletapi-2.4
	=dev-java/mx4j-core-3.0*"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPS}"
# FIXME doesn't compile with 1.6 due to JDBC api change
DEPEND="|| ( =virtual/jdk-1.5* =virtual/jdk-1.4* )
	bsf? ( >=dev-java/bsf-2.3 )
	${COMMON_DEPS}"
# needs to be keyworded
#	test? ( dev-java/jmock )

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}

	cd "${S}"
#	epatch ${FILESDIR}/${P}-compiler-exit-code.patch

	mkdir -p target/lib && cd target/lib

	java-pkg_jar-from commons-cli-1
	java-pkg_jar-from xerces-2
	java-pkg_jar-from ant-core ant.jar
	java-pkg_jar-from antlr
	java-pkg_jar-from asm-2.2
	java-pkg_jar-from xstream
	java-pkg_jar-from mockobjects
	java-pkg_jar-from junit
	java-pkg_jar-from servletapi-2.4
	java-pkg_jar-from mx4j-core-3.0
#	use test && java-pkg_jar-from --build-only jmock-1.0
	if use bsf; then
		# build-only because it's invoked only from bsf itself
		# so no need to pollute classpath
		java-pkg_jar-from --build-only bsf-2.3
	else
		cd "${S}"
		# remove the adapter classes
		rm -rf src/{main,test}/org/codehaus/groovy/bsf || die
		sed -i -e '/org.codehaus.groovy.bsf/d' -e '/BSFTest/d' \
			src/test/AllCodehausJavaTestsSuite.java || die
	fi

	cd "${S}"
	# We use ant NOT maven. This build.xml is generated using 'maven ant', and
	# then the following tweaks:
	#  - change libdir from /root/.ant/maven to target/lib
	#    NOTE this could be also simplified using -Dlibdir=target/lib
	#  - change build.classpath to use <fileset dir="${libdir}" includes="**/*.jar"/>
	#     instead of using each individual jar
	#  - remove get-deps from the depends of all targets. you should be able to
	#  define -Dnoget=true, but that doesn't really work
	#  - remove all the get-* targets (otherwise, the file is a bit oversized to
	#  be in files/
	#  - remove all the junit-present stuff
	#  - remove test dependency from jar target
	cp ${FILESDIR}/build.xml-${PV} ${S}/build.xml || die "Failed to update build.xml"

	cd src/main
	# This won't compile without an incestuous relationship with radeox.
	rm -rf org/codehaus/groovy/wiki
}

src_compile() {
	eant jar

	# need to compile .groovy files to .class files
	cd src/main
	java -classpath ../../target/${MY_P}.jar:$(java-pkg_getjars commons-cli-1,asm-2.2,antlr,junit,qdox-1.6) \
		org.codehaus.groovy.tools.FileSystemCompiler \
		$(find -name *.groovy) || die "Failed to invoke groovyc"

	# add the now compiled .class files to our jar
	jar uf ../../target/${MY_P}.jar  $(find -name *.class) || die "Failed to backpatch Console*.class"
}

src_test() {
	eant test
}

src_install() {
	java-pkg_newjar target/${MY_P}.jar
	java-pkg_dolauncher "grok" --main org.codehaus.groovy.tools.Grok
	java-pkg_dolauncher "groovyc" --main org.codehaus.groovy.tools.FileSystemCompiler
	java-pkg_dolauncher "groovy" --main groovy.ui.GroovyMain
	java-pkg_dolauncher "groovysh" --main groovy.ui.InteractiveShell
	java-pkg_dolauncher "groovyConsole" --main groovy.ui.Console
}
