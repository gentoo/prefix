# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/gnu-crypto/gnu-crypto-2.0.1-r2.ebuild,v 1.12 2012/01/01 18:05:56 sera Exp $

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 eutils

DESCRIPTION="GNU Crypto cryptographic primitives for Java"
HOMEPAGE="http://www.gnu.org/software/gnu-crypto/"
SRC_URI="ftp://ftp.gnupg.org/GnuPG/gnu-crypto/gnu-crypto-2.0.1.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=">=virtual/jdk-1.3"
RDEPEND=">=virtual/jre-1.3"

RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-jdk15.patch"
}

src_compile() {
	# jikes support disabled, doesnt work: #86655
	econf JAVAC="javac" JAVACFLAGS="$(java-pkg_javac-args)" --with-jce=yes --with-sasl=yes || die
	emake -j1 || die
	if use doc ; then
		emake -j1 javadoc || die
	fi
}

src_install() {
	einstall || die
	rm "${ED}"/usr/share/*.jar

	java-pkg_dojar source/gnu-crypto.jar
	java-pkg_dojar jce/javax-crypto.jar
	java-pkg_dojar security/javax-security.jar

	use doc && java-pkg_dojavadoc api
	use source && java-pkg_dosrc source/* jce/* security/*

	dodoc AUTHORS ChangeLog NEWS README THANKS || die
}
