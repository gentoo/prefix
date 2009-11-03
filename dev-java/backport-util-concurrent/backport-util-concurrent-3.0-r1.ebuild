# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/backport-util-concurrent/backport-util-concurrent-3.0-r1.ebuild,v 1.2 2009/11/02 21:48:00 maekke Exp $

JAVA_PKG_IUSE="doc source test"
inherit java-pkg-2 java-ant-2

DESCRIPTION="A backport of java.util.concurrent API, from Java 5.0, to 1.4, and from Java 6.0 to 5.0"
HOMEPAGE="http://www.mathcs.emory.edu/dcl/util/backport-util-concurrent/"
SRC_URI="http://dcl.mathcs.emory.edu/util/${PN}/dist/${P}/Java50/${PN}-Java50-${PV}-src.zip"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="=virtual/jdk-1.5*
	test? ( =dev-java/junit-3* )
	app-arch/unzip"
RDEPEND=">=virtual/jdk-1.5"

S="${WORKDIR}/${P}-src"

src_unpack() {
	unpack ${A}
	# This is just workaround because setting ${S} in pkg_setup doesn't currently
	# work and this seems better than doing it in global scope
	mv ${PN}-Java50-${PV}-src ${P}-src || die
	cd "${S}"

	if use test; then
		# make test not dependo n make
		epatch "${FILESDIR}/${P}-test.patch"
	else
		# don't compile test classes
		epatch "${FILESDIR}/${P}-notest.patch"
	fi

	cd "${S}/external"
	rm -v *.jar || die

	use test && java-pkg_jar-from --build-only junit
}

EANT_BUILD_TARGET="javacompile archive"

src_test() {
	eant test
}

src_install() {
	java-pkg_dojar ${PN}.jar
	dohtml README.html || die

	use doc && java-pkg_dojavadoc doc/api
	use source && java-pkg_dosrc src/*
}
