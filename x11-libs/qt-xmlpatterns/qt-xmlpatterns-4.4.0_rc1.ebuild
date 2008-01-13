# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-xmlpatterns/qt-xmlpatterns-4.4.0_rc1.ebuild,v 1.3 2007/12/22 18:17:11 caleb Exp $

EAPI="prefix"

inherit qt4-build

SRCTYPE="preview-opensource-src"
DESCRIPTION="The patternist module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

MY_PV=${PV/_rc/-tp}

SRC_URI="!aqua? ( ftp://ftp.trolltech.com/pub/qt/source/qt-x11-${SRCTYPE}-${MY_PV}.tar.gz )
	aqua? ( ftp://ftp.trolltech.com/pub/qt/source/qt-mac-${SRCTYPE}-${MY_PV}.tar.gz )"
use aqua || S=${WORKDIR}/qt-x11-${SRCTYPE}-${MY_PV}
use aqua && S=${WORKDIR}/qt-mac-${SRCTYPE}-${MY_PV}

LICENSE="|| ( QPL-1.0 GPL-2 )"
SLOT="4"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"

RDEPEND="~x11-libs/qt-core-${PV}"

DEPEND="${RDEPEND}"

QT4_TARGET_DIRECTORIES="src/xmlpatterns tools/patternist"

src_unpack() {

	qt4-build_src_unpack

	skip_qmake_build_patch
	skip_project_generation_patch
	install_binaries_to_buildtree
}

src_compile() {
	local myconf=$(standard_configure_options)
	myconf="${myconf} -xmlpatterns"

	echo ./configure ${myconf}
	./configure ${myconf} || die

	build_target_directories
}

pkg_postinst()
{
	qconfig_add_option xmlpatterns
}

pkg_postrm()
{
	qconfig_remove_option xmlpatterns
}
