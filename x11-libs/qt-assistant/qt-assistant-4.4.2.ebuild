# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-assistant/qt-assistant-4.4.2.ebuild,v 1.2 2008/10/01 20:13:13 yngwin Exp $

EAPI="prefix 1"
inherit qt4-build

DESCRIPTION="The assistant help module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="+webkit"

DEPEND="~x11-libs/qt-gui-${PV}
	~x11-libs/qt-sql-${PV}
	!alpha? ( !ia64? ( !ppc? ( webkit? ( ~x11-libs/qt-webkit-${PV} ) ) ) )
	!<=x11-libs/qt-4.4.0_alpha:${SLOT}"
RDEPEND="${DEPEND}"

# Pixeltool isn't really assistant related, but it relies on
# the assistant libraries.
QT4_TARGET_DIRECTORIES="tools/assistant tools/pixeltool"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
doc/qch/
src/3rdparty/clucene/
tools/shared/fontpanel"

pkg_setup() {
	qt4-build_pkg_setup

	if ! built_with_use x11-libs/qt-sql sqlite; then
		die "You must first emerge x11-libs/qt-sql with the \"sqlite\" use flag in order to use qt-assistant"
	fi
}

src_compile() {
	local myconf
	myconf="${myconf} -no-xkb -no-tablet -no-fontconfig -no-xrender -no-xrandr
		-no-xfixes -no-xcursor -no-xinerama -no-xshape -no-sm -no-opengl
		-no-nas-sound -no-dbus -iconv -no-cups -no-nis -no-gif -no-libpng
		-no-libmng -no-libjpeg -no-openssl -system-zlib -no-phonon
		-no-xmlpatterns -no-freetype -no-libtiff -no-accessibility
		-no-fontconfig -no-glib -no-opengl -no-qt3support -no-svg"
	if use webkit; then
		myconf="$myconf -assistant-webkit"
	else
		myconf="$myconf -no-webkit"
	fi

	qt4-build_src_compile
}

src_install() {
	qt4-build_src_install
	domenu "${FILESDIR}"/Assistant.desktop || die "domenu failed"

	insinto ${QTDOCDIR}
	doins -r doc/qch/ || die 'Installing qch files failed.'
}
