# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jsch/jsch-0.1.36.ebuild,v 1.2 2007/11/26 20:15:18 betelgeuse Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source examples"

inherit java-pkg-2 java-ant-2

DESCRIPTION="JSch is a pure Java implementation of SSH2."
HOMEPAGE="http://www.jcraft.com/jsch/"
SRC_URI="mirror://sourceforge/${PN}/${P}.zip"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND=">=virtual/jdk-1.4
	>=dev-java/jzlib-1.0.3"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${RDEPEND}"

src_compile() {
	# for ANT_TASKS see
	# https://bugs.gentoo.org/show_bug.cgi?id=200309
	ANT_TASKS="none" eant -Dproject.cp="$(java-pkg_getjars jzlib)" dist $(use_doc)
}

src_install() {
	java-pkg_newjar dist/lib/jsch*.jar
	dodoc README ChangeLog || die
	use doc && java-pkg_dojavadoc javadoc
	use source && java-pkg_dosrc src/*
	use examples && java-pkg_doexamples examples
}
