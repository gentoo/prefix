# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/servletapi/servletapi-2.3-r3.ebuild,v 1.10 2007/01/19 21:41:06 corsair Exp $

EAPI="prefix"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Servlet API 2.3 from jakarta.apache.org"
HOMEPAGE="http://jakarta.apache.org/"
SRC_URI="mirror://gentoo/${P}-20021101.tar.gz"

LICENSE="Apache-1.1"
SLOT="2.3"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.4
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.3"
S="${WORKDIR}/jakarta-servletapi-4"

src_compile() {
	eant all
}

src_install() {
	java-pkg_dojar dist/lib/servlet.jar

	use doc && java-pkg_dohtml -r dist/docs/*
	use source && java-pkg_dosrc src/share/javax
	dodoc dist/README.txt
}
