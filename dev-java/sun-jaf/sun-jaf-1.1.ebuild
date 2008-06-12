# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-jaf/sun-jaf-1.1.ebuild,v 1.9 2007/04/18 20:21:21 betelgeuse Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Sun's JavaBeans Activation Framework (JAF)"
HOMEPAGE="http://java.sun.com/products/javabeans/glasgow/jaf.html"
# CVS:
# View: https://glassfish.dev.java.net/source/browse/glassfish/activation/?only_with_tag=JAF-1_1
# How-To: https://glassfish.dev.java.net/servlets/ProjectSource
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="CDDL"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4"
S="${WORKDIR}/activation"

JAVA_PKG_BSFIX="off"

EANT_DOC_TARGET="docs"

src_install() {
	java-pkg_dojar build/release/activation.jar
	use doc && java-pkg_dojavadoc build/release/docs/javadocs
	use source && java-pkg_dosrc src/java
}
