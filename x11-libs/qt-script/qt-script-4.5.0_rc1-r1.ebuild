# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-script/qt-script-4.5.0_rc1-r1.ebuild,v 1.1 2009/02/14 00:56:52 hwoarang Exp $

EAPI="prefix 2"
inherit qt4-build

DESCRIPTION="The ECMAScript module for the Qt toolkit"
LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="~x11-libs/qt-core-${PV}[debug=]"
RDEPEND="${DEPEND}"
PDEPEND="~x11-libs/qt-gui-${PV}"

QT4_TARGET_DIRECTORIES="src/script/ src/scripttools/"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
include/Qt/
include/QtCore/
include/QtScriptTools/
include/QtGui/
include/QtScript/
src/corelib/
src/gui"

src_configure() {
	myconf="${myconf} -no-xkb  -no-fontconfig -no-xrender -no-xrandr
		-no-xfixes -no-xcursor -no-xinerama -no-xshape -no-sm -no-opengl
		-no-nas-sound -no-dbus -iconv -no-cups -no-nis -no-gif -no-libpng
		-no-libmng -no-libjpeg -no-openssl -system-zlib -no-webkit -no-phonon
		-no-qt3support -no-xmlpatterns -no-freetype -no-libtiff -no-accessibility
		-no-fontconfig -no-glib -no-opengl -no-svg -no-gtkstyle"
	qt4-build_src_configure
}
