# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/batik/batik-1.6-r4.ebuild,v 1.2 2009/05/20 20:31:34 caster Exp $

JAVA_PKG_IUSE="doc"
EAPI=2
inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="Java based SVG toolkit"
HOMEPAGE="http://xml.apache.org/batik/"
SRC_URI="mirror://apache/xml/batik/${PN}-src-${PV}.zip"

LICENSE="Apache-2.0"
SLOT="1.6"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="python tcl"

CDEPEND="dev-java/rhino:1.5
	dev-java/xerces:2
	dev-java/xml-commons-external:1.3
	python? ( dev-java/jython:0 )
	tcl? ( dev-java/jacl:0 )
	dev-java/ant-core"
DEPEND="=virtual/jdk-1.4*
	app-arch/unzip
	${CDEPEND}"
RDEPEND=">=virtual/jre-1.4
	${CDEPEND}"

S="${WORKDIR}/xml-${PN}"

java_prepare() {
	epatch "${FILESDIR}/${P}-jikes.patch"
	epatch "${FILESDIR}/${P}-dont-copy-deps.patch"

	java-ant_ignore-system-classes
	java-ant_rewrite-classpath contrib/rasterizertask/build.xml
	cd lib
	rm -f *.jar build/*.jar

	java-pkg_jar-from xml-commons-external-1.3
	java-pkg_jar-from xerces-2
	# Can't make rhino optional because
	# apps/svgbrowser needs it
	java-pkg_jar-from rhino-1.5
	use python && java-pkg_jar-from jython
	use tcl && java-pkg_jar-from jacl
}

src_compile() {
	# Fails to build on amd64 without this
	if use amd64 ; then
		export ANT_OPTS="-Xmx1g"
	else
		export ANT_OPTS="-Xmx256m"
	fi

	eant jars all-jar $(use_doc)
	cd contrib/rasterizertask || die
	eant -Dgentoo.classpath="$(java-pkg_getjar ant-core ant.jar):../../classes" jar $(use_doc)
}

src_install() {
	java-pkg_dojar ${P}/batik*.jar

	cd ${P}/lib

	# needed because batik expects this layout:
	# batik.jar lib/*.jar
	# there are hardcoded classpaths in the manifest :(
	dodir /usr/share/${PN}-${SLOT}/lib/lib/
	for jar in *.jar
	do
		java-pkg_dojar ${jar}
		dosym ../${jar} /usr/share/${PN}-${SLOT}/lib/lib/${jar}
	done

	cd "${S}"
	dodoc README || die "dodoc failed"
	use doc && java-pkg_dojavadoc ${P}/docs/javadoc

	# pwd fixes bug #116976
	java-pkg_dolauncher batik-${SLOT} --pwd "${EPREFIX}/usr/share/${PN}-${SLOT}/" \
		--main org.apache.batik.apps.svgbrowser.Main

	# To find these lsjar batik-${SLOT} | grep Main.class
	for launcher in ttf2svg slideshow svgpp rasterizer; do
		java-pkg_dolauncher batik-${launcher}-${SLOT} \
			--main org.apache.batik.apps.${launcher}.Main
	done

	# Install and register the ant task.
	java-pkg_dojar contrib/rasterizertask/build/lib/RasterizerTask.jar
	java-pkg_register-ant-task
}
