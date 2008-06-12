# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-jaf/sun-jaf-1.1.1.ebuild,v 1.5 2008/03/11 15:17:50 ranger Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Sun's JavaBeans Activation Framework (JAF)"
HOMEPAGE="http://java.sun.com/products/javabeans/glasgow/jaf.html"
# CVS:
# View: https://glassfish.dev.java.net/source/browse/glassfish/activation/?only_with_tag=JAF-1_1
# How-To: https://glassfish.dev.java.net/servlets/ProjectSource
SRC_URI="mirror://gentoo/${P}.tar.bz2"

# Remember to pray that bootstrap HEAD works
#cvs -d:pserver:guest@cvs.dev.java.net:/cvs export -r JAF-${PV/./_} glassfish/activation
#cvs -d:pserver:guest@cvs.dev.java.net:/cvs export -r HEAD glassfish/bootstrap
#find . -name \*.jar -delete
#tar cvjf ${P}.tar.bz glassfish
#upload

LICENSE="CDDL"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4"
S="${WORKDIR}/glassfish/activation"

JAVA_PKG_BSFIX="off"

EANT_DOC_TARGET="docs"

src_install() {
	java-pkg_dojar build/release/activation.jar
	use doc && java-pkg_dojavadoc build/release/docs/javadocs
	use source && java-pkg_dosrc src/java
}
