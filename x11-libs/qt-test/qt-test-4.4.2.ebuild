# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-test/qt-test-4.4.2.ebuild,v 1.9 2009/03/01 11:00:58 alexxy Exp $

EAPI=1
inherit qt4-build

DESCRIPTION="The testing framework module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="~x11-libs/qt-core-${PV}
	!<=x11-libs/qt-4.4.0_alpha:${SLOT}"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="src/testlib"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}"

src_compile() {
	local myconf
	myconf="${myconf} -no-xkb -no-tablet -no-fontconfig -no-xrender -no-xrandr
		-no-xfixes -no-xcursor -no-xinerama -no-xshape -no-sm -no-opengl
		-no-nas-sound -no-dbus -iconv -no-cups -no-nis -no-gif -no-libpng
		-no-libmng -no-libjpeg -no-openssl -system-zlib -no-webkit -no-phonon
		-no-qt3support -no-xmlpatterns -no-freetype -no-libtiff -no-accessibility
		-no-fontconfig -no-glib -no-opengl -no-svg"

	qt4-build_src_compile
}
