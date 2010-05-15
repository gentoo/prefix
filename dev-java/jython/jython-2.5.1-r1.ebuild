# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jython/jython-2.5.1-r1.ebuild,v 1.2 2010/03/20 13:17:20 arfrever Exp $

JAVA_PKG_IUSE="source doc examples oracle"
#informix missing.  This is a jdbc driver, similar to oracle use flag
#functionality.

EAPI="2"

inherit base java-pkg-2 java-ant-2

DESCRIPTION="An implementation of Python written in Java"
HOMEPAGE="http://www.jython.org"

PYVER="2.5.5"

SRC_URI="http://www.python.org/ftp/python/${PYVER%_*}/Python-${PYVER}.tgz
	mirror://gentoo/${P}.tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.5"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

#>=dev-java/jdbc-mysql-3.1
#dev-java/jdbc-postgresql
CDEPEND="=dev-java/jakarta-oro-2.0*
	>=dev-java/libreadline-java-0.8.0
	dev-java/asm:3
	oracle? ( dev-java/jdbc-oracle-bin:10.2 )
	java-virtuals/servlet-api:2.5
	!<=dev-java/freemarker-2.3.10
	dev-java/constantine:0
	dev-java/jline:0
	dev-java/jna-posix:0
	dev-java/jna:0
	dev-java/antlr:0
	dev-java/antlr:3
	dev-java/stringtemplate:0
	dev-java/xerces:2
	dev-java/jsr223:0"
RDEPEND=">=virtual/jre-1.5
	${CDEPEND}"
DEPEND=">=virtual/jdk-1.5
		dev-java/ant-core:0
		dev-java/junit:0
		${CDEPEND}"

java_prepare() {
	epatch "${FILESDIR}/${P}-build.patch"
	epatch "${FILESDIR}/${P}-distutils_scripts_location.patch"
	epatch "${FILESDIR}/${P}-respect_PYTHONPATH.patch"

	rm -Rfv org || die "Unable to remove class files."
	find extlibs -iname '*.jar' | xargs rm -fv || die "Unable to remove bundled jars"
	find "${WORKDIR}" -iname '*.pyc' | xargs rm -fv
	java-pkg_jar-from --into extlibs libreadline-java libreadline-java.jar \
		libreadline-java-0.8.jar
	java-pkg_jar-from --into extlibs antlr-3 antlr3.jar antlr-3.1.3.jar
	java-pkg_jar-from --into extlibs antlr antlr.jar antlr-2.7.7.jar
	java-pkg_jar-from --into extlibs stringtemplate stringtemplate.jar \
		stringtemplate-3.2.jar
	java-pkg_jar-from --into extlibs servlet-api-2.5 servlet-api.jar \
		servlet-api-2.5.jar
	java-pkg_jar-from --into extlibs asm-3 asm.jar asm-3.1.jar
	java-pkg_jar-from --into extlibs asm-3 asm-commons.jar \
		asm-commons-3.1.jar
	java-pkg_jar-from --into extlibs constantine constantine.jar \
		constantine-0.4.jar
	java-pkg_jar-from --into extlibs jline jline.jar \
		jline-0.9.95-SNAPSHOT.jar
	java-pkg_jar-from --into extlibs jna jna.jar
	java-pkg_jar-from --into extlibs jna-posix jna-posix.jar
	java-pkg_jar-from --build-only --into extlibs ant-core ant.jar
	java-pkg_jar-from --build-only --into extlibs junit junit.jar \
		junit-3.8.2.jar
	java-pkg_jar-from --into extlibs xerces-2 xercesImpl.jar
	java-pkg_jar-from --into extlibs jsr223 script-api.jar \
		livetribe-jsr223-2.0.5.jar

	echo "has.repositories.connection=false" > ant.properties

	if use oracle; then
		echo \
		"oracle.jar=$(java-pkg-getjar jdbc-oracle-bin-10.2 ojdbc14.jar)" \
		>> ant.properties
	fi
}

src_compile() {
	local antflags=""
	local pylib="../Python-${PYVER}/Lib"
	antflags="${antflags} -Dpython.lib=${pylib}"
	eant ${antflags} developer-build $(use_doc javadoc)
}

# Restrict tests as some dont compile and others (a couple) are broken.
RESTRICT="test"
src_test() {
#[exec] 311 tests OK.
#[exec] 3 tests skipped:
#[exec]     test_subprocess test_urllib2net test_urllibnet
#[exec] 2 tests failed:
#[exec]     test_pbcvm test_pkgimport
#[exec] 2 fails unexpected:
#[exec]     test_pbcvm test_pkgimport
	local antflags=""
	antflags="${antflags} -Dgentoo.library.path=$(java-config -di jna-posix)"
	antflags="${antflags} -Dpython.home=dist"
	local pylib="../Python-${PYVER}/Lib"
	antflags="${antflags} -Dpython.lib=${pylib}"
	ANT_TASKS="ant-junit" eant ${antflags} test
}

src_install() {
	dodoc README.txt NEWS ACKNOWLEDGMENTS README.txt
	cd dist || die
	java-pkg_newjar "${PN}-dev.jar"

	local java_args="-Dpython.home=${EPREFIX}/usr/share/${PN}-${SLOT}"
	java_args="${java_args} -Dpython.cachedir=\${JYTHON_CACHEDIR-\${HOME}/.jythoncachedir}"
	java_args="${java_args} -Dpython.executable=${EROOT}/usr/bin/jython-${SLOT}"

	java-pkg_dolauncher jython-${SLOT} \
						--main "org.python.util.jython" \
						--pkg_args "${java_args}"
	sed -e "1a unset EPYTHON" -i "${ED}usr/bin/${PN}-${SLOT}" || die "sed failed"

	java-pkg_register-optional-dependency jdbc-mysql
	java-pkg_register-optional-dependency jdbc-postgresql

	insinto /usr/share/${PN}-${SLOT}
	doins -r Lib registry

	use doc && java-pkg_dojavadoc Doc/javadoc
	use source && java-pkg_dosrc ../src
	cd "${S}"
	use examples && java-pkg_doexamples Demo/*
}

pkg_postinst() {
	einfo "Version of jython > 2.2* no longer has jythonc. Please see"
	einfo "http://www.jython.org/Project/jythonc.html for details"

	elog
	elog "To use readline you need to add the following to your registry"
	elog
	elog "python.console=org.python.util.ReadlineConsole"
	elog "python.console.readlinelib=GnuReadline"
	elog
	elog "The global registry can be found in /usr/share/${PN}/registry"
	elog "User registry in \$HOME/.jython"
	elog "See http://www.jython.org/docs/registry.html for more information"
	elog
}
