# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jzlib/jzlib-1.0.7-r1.ebuild,v 1.11 2007/07/11 19:58:37 mr_bones_ Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="JZlib is a re-implementation of zlib in pure Java."
HOMEPAGE="http://www.jcraft.com/jzlib/"
SRC_URI="http://www.jcraft.com/${PN}/${P}.tar.gz"

LICENSE="jcraft"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4"

src_unpack() {
	unpack ${A}
	cp "${FILESDIR}/jzlib_build.xml" "${S}/build.xml" || die
	mkdir "${S}/src" || die
	mv "${S}/com/" "${S}/src/" || die
}

EANT_BUILD_TARGET="dist"

src_install() {
	java-pkg_newjar dist/lib/jzlib*.jar jzlib.jar
	use doc && java-pkg_dojavadoc javadoc
	use source && java-pkg_dosrc src
	dodoc README ChangeLog || die
}
