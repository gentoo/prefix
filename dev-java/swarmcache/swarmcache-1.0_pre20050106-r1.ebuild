# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/swarmcache/swarmcache-1.0_pre20050106-r1.ebuild,v 1.2 2007/04/25 19:17:53 nelchael Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="SwarmCache is a simple but effective distributed cache."
SRC_URI="mirror://gentoo/${P}.tar.bz2"
HOMEPAGE="http://swarmcache.sourceforge.net"
LICENSE="LGPL-2"
SLOT="1.0"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE=""

COMMON_DEP=">=dev-java/commons-collections-3
	>=dev-java/commons-logging-1.0.4
	>=dev-java/jgroups-2.2.7"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

DEPEND=">=virtual/jdk-1.4
	${COMMON_DEP}
	>=dev-java/ant-core-1.5"

src_unpack() {
	unpack ${A}

	cd "${S}/lib"
	java-pkg_jar-from commons-collections
	java-pkg_jar-from commons-logging
	java-pkg_jar-from jgroups
}

#Tests seem to start a server that just waits
#src_test() {
#	eant test
#}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	dodoc *.txt
	use doc && java-pkg_dojavadoc web/api
	use source && java-pkg_dosrc src/net
}
