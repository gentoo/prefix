# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/asm/asm-2.2.3-r1.ebuild,v 1.2 2007/07/11 19:58:37 mr_bones_ Exp $

EAPI="prefix"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Bytecode manipulation framework for Java"
HOMEPAGE="http://asm.objectweb.org"
SRC_URI="http://download.forge.objectweb.org/${PN}/${P}.tar.gz"
LICENSE="BSD"
SLOT="2.2"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc source"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	dev-java/ant-owanttask
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

src_unpack() {
	unpack ${A}

	cd ${S}
	# disables test coverage stuff
	epatch ${FILESDIR}/${P}-build.xml.patch
	# see bug #153971 and http://forge.objectweb.org/tracker/index.php?func=detail&aid=306349&group_id=23&atid=100023
	epatch ${FILESDIR}/${P}-commons.patch
	echo "objectweb.ant.tasks.path = $(java-pkg_getjar --build-only ant-owanttask ow_util_ant_tasks.jar)" >> build.properties
}

src_compile() {
	eant jar $(use_doc jdoc)
}

src_install() {
	for x in output/dist/lib/*.jar ; do
		java-pkg_newjar ${x} $(basename ${x/-${PV}})
	done
	use doc && java-pkg_dohtml -r output/dist/doc/javadoc/user/*
	use source && java-pkg_dosrc src/*
}
