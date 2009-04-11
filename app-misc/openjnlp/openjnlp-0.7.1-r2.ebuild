# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/openjnlp/openjnlp-0.7.1-r2.ebuild,v 1.8 2007/10/24 02:30:53 wltjr Exp $

WANT_ANT_TASKS="ant-nodeps"

inherit java-pkg-2 java-ant-2

DESCRIPTION="An open-source implementation of the JNLP"
HOMEPAGE="http://openjnlp.nanode.org/"
SRC_URI="mirror://sourceforge/openjnlp/OpenJNLP-src-rel_ver-${PV//./-}.zip"
LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
RDEPEND=">=virtual/jre-1.4
		dev-java/sax
		dev-java/jnlp-bin
		dev-java/nanoxml"
DEPEND=">=virtual/jdk-1.4
		${RDEPEND}
		app-arch/unzip"

S="${WORKDIR}/OpenJNLP-src-rel_ver-${PV//./-}"

src_unpack() {
	unpack ${A}
	cd "${S}/jars"
	rm -v *.jar || die
	java-pkg_jar-from jnlp-bin
	java-pkg_jar-from sax
	java-pkg_jar-from nanoxml nanoxml.jar nanoxml-2.2.jar
	java-pkg_jar-from nanoxml nanoxml-sax.jar nanoxml-sax-2.2.jar

	sed -e "s/<javac/<javac target=\"$(java-pkg_get-target)\" source=\"$(java-pkg_get-source)\"/" \
		-i "${S}/targets/common.xml" || die "failed to sed javac"
	java-ant_rewrite-classpath "${S}/targets/OpenJNLP/build.xml"
}

src_compile() {
	cd "${S}"/targets
	eant -Dgentoo.classpath=jars/MRJToolkitStubs.zip build
}

src_install() {
	cd "${S}"/build/apps/unix/OpenJNLP-${PV}/

	java-pkg_dojar lib/*.jar
	java-pkg_dolauncher ${PN} --main org.nanode.app.OpenJNLP

	dodoc {History,ReadMe}.txt || die
}
