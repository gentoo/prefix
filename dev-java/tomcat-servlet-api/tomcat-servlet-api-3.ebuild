# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/tomcat-servlet-api/tomcat-servlet-api-3.ebuild,v 1.3 2008/05/30 17:18:39 ken69267 Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

MY_PN="${PN/tomcat/}"
MY_PN="jakarta-${MY_PN//-/}-src"
DESCRIPTION="Tomcat's Servlet API 2.2/JSP API 1.2 implementation"
HOMEPAGE="http://tomcat.apache.org/"
SRC_URI="http://archive.apache.org/dist/jakarta/tomcat-3/src/${MY_PN}.tar.gz"
DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4"
LICENSE="Apache-1.1"
SLOT="2.2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""
S="${WORKDIR}/${MY_PN}"

EANT_BUILD_TARGET="all"

src_install() {
	java-pkg_dojar ../dist/servletapi/lib/servlet.jar

	use doc && java-pkg_dohtml -r ../dist/servletapi/docs/*
	use source && java-pkg_dosrc src/share/javax
	dodoc ../dist/README.txt
}
