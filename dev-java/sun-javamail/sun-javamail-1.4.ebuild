# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-javamail/sun-javamail-1.4.ebuild,v 1.13 2007/11/25 08:00:39 caster Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2

DESCRIPTION="A Java-based framework to build multiplatform mail and messaging applications."
HOMEPAGE="http://java.sun.com/products/javamail/index.html"
# CVS:
# View: https://glassfish.dev.java.net/source/browse/glassfish/mail/?only_with_tag=JAVAMAIL-1_4
# How-To: https://glassfish.dev.java.net/servlets/ProjectSource
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="CDDL"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

DEPEND=">=virtual/jdk-1.5
	dev-java/sun-jaf"
RDEPEND=">=virtual/jre-1.4
	dev-java/sun-jaf"
S="${WORKDIR}/mail"

JAVA_PKG_WANT_SOURCE="1.4"
JAVA_PKG_WANT_TARGET="1.4"

src_unpack() {
	unpack ${A}
	cd "${S}"
	java-pkg_jar-from sun-jaf activation.jar activation-real.jar
	cp -L activation-real.jar activation.jar
}

src_compile() {
	eant -Djavaee.jar=activation.jar jar $(use_doc docs)
}

src_install() {
	java-pkg_dojar build/release/mail.jar
	use doc && java-pkg_dojavadoc build/release/docs/javadocs
	use source && java-pkg_dosrc src/java
}
