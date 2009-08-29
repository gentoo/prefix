# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jcodings/jcodings-1.0.2.ebuild,v 1.3 2009/07/05 20:34:45 maekke Exp $

EAPI="2"
JAVA_PKG_IUSE="source"
inherit base java-pkg-2 java-ant-2

DESCRIPTION="Byte-based encoding support library for Java"
HOMEPAGE="http://jruby.codehaus.org/"
# does not seem to create stable results, mirror is safer
#SRC_URI="http://svn.jruby.codehaus.org/browse/~tarball=tbz2/jruby/${PN}/tags/${PV}/${PV}.tbz2 -> ${P}.tar.bz2"
SRC_URI="mirror://gentoo/${P}.tar.bz2"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

EANT_BUILD_TARGET="build"
S="${WORKDIR}"

src_install() {
	java-pkg_dojar target/${PN}.jar
	use source && java-pkg_dosrc src/*
}
