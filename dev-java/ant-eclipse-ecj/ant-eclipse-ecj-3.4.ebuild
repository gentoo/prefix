# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-eclipse-ecj/ant-eclipse-ecj-3.4.ebuild,v 1.3 2009/04/24 02:03:06 ranger Exp $

inherit java-pkg-2

DMF="R-${PV}-200806172000"
S="${WORKDIR}"

DESCRIPTION="Ant Compiler Adapter for Eclipse Java Compiler"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/${DMF/.0}/ecjsrc-${PV}.zip"

LICENSE="EPL-1.0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
SLOT="3.4"
IUSE=""

RDEPEND=">=virtual/jre-1.4
	~dev-java/eclipse-ecj-${PV}
	>=dev-java/ant-core-1.7"
DEPEND="${RDEPEND}
	app-arch/unzip
	>=virtual/jdk-1.4
	sys-apps/findutils"

src_unpack() {
	unpack ${A}
	mkdir -p src/org/eclipse/jdt/{core,internal}
	cp org/eclipse/jdt/core/JDTCompilerAdapter.java \
		src/org/eclipse/jdt/core || die
	cp -r org/eclipse/jdt/internal/antadapter \
		src/org/eclipse/jdt/internal || die
	rm -fr about* org
}

src_compile() {
	cd src
	ejavac -classpath "$(java-pkg_getjars ant-core,eclipse-ecj-${SLOT})" \
		$(find org/ -name '*.java') || die "ejavac failed!"
	find org/ -name '*.class' -o -name '*.properties' | \
			xargs jar cf "${S}/${PN}.jar" || die "jar failed!"
}

src_install() {
	java-pkg_dojar ${PN}.jar
	insinto /usr/share/java-config-2/compiler
	newins "${FILESDIR}/compiler-settings-${SLOT}" ecj-${SLOT}
	dosed "/^JAVAC/s:/usr/bin/ecj:${EPREFIX}/usr/bin/ecj" /usr/share/java-config-2/compiler/ecj-${SLOT}
}
