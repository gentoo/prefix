# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/checkstyle/checkstyle-4.3.ebuild,v 1.4 2007/11/25 15:52:01 ranger Exp $

EAPI="prefix"

WANT_ANT_TASKS="ant-antlr ant-nodeps"
JAVA_PKG_IUSE="doc source test"

inherit java-pkg-2 java-ant-2

MY_P="${PN}-src-${PV}"
DESCRIPTION="A development tool to help programmers write Java code that adheres to a coding standard."
HOMEPAGE="http://checkstyle.sourceforge.net"
SRC_URI="mirror://sourceforge/checkstyle/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"

COMMON_DEP="dev-java/antlr
	=dev-java/commons-beanutils-1.7*
	=dev-java/commons-cli-1*
	dev-java/commons-logging
	dev-java/commons-collections"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

# Tests are a bit buggy and fail with 1.5 in one case
# Should be fixed in the next release
DEPEND="!test? ( >=virtual/jdk-1.4 )
	test? ( =virtual/jdk-1.6* )
	${COMMON_DEP}
	test? (
		dev-java/ant-junit
		dev-java/ant-trax
		dev-java/emma
	)"

S="${WORKDIR}/${MY_P}"

# So that we can generate 1.4 bytecode for dist
# and 1.5 for tests
JAVA_PKG_BSFIX="off"

src_unpack() {
	unpack ${A}
	cd "${S}/lib"
	rm -v *.jar || die
	java-pkg_jar-from antlr
	java-pkg_jar-from commons-beanutils-1.7
	java-pkg_jar-from commons-cli-1
	java-pkg_jar-from commons-logging
	java-pkg_jar-from commons-collections
}

src_compile() {
	eant compile.checkstyle $(use_doc)
	jar cfm ${PN}.jar config/manifest.mf -C target/checkstyle . || die "jar failed"
}

src_test() {
	# 1.6 on ppc. Remember to remove from package.use.mask when 1.6 is out
	if use !ppc; then
		cd "${S}/lib"
		java-pkg_jar-from --build-only junit
		java-pkg_jar-from --build-only emma
		cd "${S}"
		ANT_TASKS="emma ant-nodeps ant-junit ant-trax" eant run.tests
	fi
}

src_install() {
	java-pkg_dojar ${PN}.jar

	dodoc README RIGHTS.antlr || die
	use doc && java-pkg_dojavadoc target/docs/api
	use source && java-pkg_dosrc src/${PN}/com

	# Install check files
	insinto /usr/share/checkstyle/checks
	for file in *.xml; do
		[[ "${file}" != build.xml ]] && doins ${file}
	done

	# Install extra files
	insinto  /usr/share/checkstyle/contrib
	doins -r contrib/*

	java-pkg_dolauncher ${PN} \
		--main com.puppycrawl.tools.checkstyle.Main

	java-pkg_dolauncher ${PN}-gui \
		--main com.puppycrawl.tools.checkstyle.gui.Main

	# Make the ant tasks available to ant
	java-pkg_register-ant-task
}

pkg_postinst() {
	elog "Checkstyle is located at /usr/bin/checkstyle"
	elog "Check files are located in /usr/share/checkstyle/checks/"
}
