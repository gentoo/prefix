# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-assistant/qt-assistant-4.4.0_rc1.ebuild,v 1.6 2008/01/22 14:11:44 caleb Exp $

EAPI="prefix"

inherit qt4-build

SRCTYPE="preview-opensource-src"
DESCRIPTION="The assistant help module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

MY_PV=${PV/_rc/-tp}

SRC_URI="!aqua? ( ftp://ftp.trolltech.com/pub/qt/source/qt-x11-${SRCTYPE}-${MY_PV}.tar.gz )
	aqua? ( ftp://ftp.trolltech.com/pub/qt/source/qt-mac-${SRCTYPE}-${MY_PV}.tar.gz )"
use aqua || S=${WORKDIR}/qt-x11-${SRCTYPE}-${MY_PV}
use aqua && S=${WORKDIR}/qt-mac-${SRCTYPE}-${MY_PV}

LICENSE="|| ( QPL-1.0 GPL-2 )"
SLOT="4"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"

RDEPEND="~x11-libs/qt-gui-${PV}
	~x11-libs/qt-sql-${PV}"

DEPEND="${RDEPEND}"

# pixeltool isn't really assistant related, but it relies on
# the assistant libraries, so we'll put it here for now

QT4_TARGET_DIRECTORIES="tools/assistant tools/pixeltool"

src_unpack() {
	qt4-build_src_unpack

	skip_qmake_build_patch
	skip_project_generation_patch
	install_binaries_to_buildtree
}

src_compile() {
	local myconf=$(standard_configure_options)

	myconf="${myconf} -no-xkb -no-tablet -no-fontconfig -no-xrender -no-xrandr -no-xfixes -no-xcursor \
	-no-xinerama -no-xshape -no-sm -no-opengl -no-nas-sound -no-qdbus -iconv -no-cups -no-nis \
	-no-gif -no-libpng -no-libmng -no-libjpeg -no-openssl -system-zlib -no-webkit -no-phonon \
	-no-xmlpatterns -no-freetype -no-libtiff  -no-accessibility -no-fontconfig -no-glib -no-opengl -no-qt3support"

	echo ./configure ${myconf}
	./configure ${myconf} || die

	build_target_directories
}

src_install() {
	qt4-build_src_install
	insinto /usr/share/applications
	doins "${FILESDIR}"/Assistant.desktop
}

pkg_setup() {
	qt4-build_pkg_setup

	if ! built_with_use x11-libs/qt-sql sqlite; then
		die "You must first emerge x11-libs/qt-sql with the \"sqlite\" use flag in order to use qt-assistant"
	fi
}
