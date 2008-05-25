# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-cli/commons-cli-1.1.ebuild,v 1.2 2008/05/23 19:57:10 betelgeuse Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source test"

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="A Java library for working with the command line arguments and options."
HOMEPAGE="http://commons.apache.org/cli/"
MY_P=${P}-src
SRC_URI="mirror://apache/commons/cli/source/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

RDEPEND=">=virtual/jre-1.4"
# Blocking junit for https://bugs.gentoo.org/show_bug.cgi?id=215659
DEPEND=">=virtual/jdk-1.4
	!<dev-java/junit-3.8.2
	test? ( dev-java/ant-junit )"

S=${WORKDIR}/${MY_P}

JAVA_ANT_REWRITE_CLASSPATH="true"

src_install() {
	java-pkg_newjar target/${P}.jar

	dodoc README.txt RELEASE-NOTES.txt || die
	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/org
}
