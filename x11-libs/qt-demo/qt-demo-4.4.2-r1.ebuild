# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-demo/qt-demo-4.4.2-r1.ebuild,v 1.1 2009/02/01 22:43:43 yngwin Exp $

EAPI=1
inherit qt4-build

DESCRIPTION="Demonstration module of the Qt toolkit"
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="~x11-libs/qt-assistant-${PV}:${SLOT}
	~x11-libs/qt-core-${PV}:${SLOT}
	~x11-libs/qt-dbus-${PV}:${SLOT}
	~x11-libs/qt-gui-${PV}:${SLOT}
	~x11-libs/qt-opengl-${PV}:${SLOT}
	~x11-libs/qt-qt3support-${PV}:${SLOT}
	~x11-libs/qt-script-${PV}:${SLOT}
	~x11-libs/qt-sql-${PV}:${SLOT}
	~x11-libs/qt-svg-${PV}:${SLOT}
	~x11-libs/qt-test-${PV}:${SLOT}
	~x11-libs/qt-webkit-${PV}:${SLOT}
	~x11-libs/qt-xmlpatterns-${PV}:${SLOT}
	|| ( ~x11-libs/qt-phonon-${PV}:${SLOT} media-sound/phonon )"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="demos
	examples"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
	doc/src/images"

src_compile() {
	# Doesn't find qt-gui and fails linking
	sed -e '/QT_BUILD_TREE/ s:=:+=:' \
		-i "${S}"/examples/tools/plugandpaint/plugandpaint.pro \
		|| die "Fixing plugandpaint example failed."

	qt4-build_src_compile
}

src_install() {
	insinto "${QTDOCDIR##${EPREFIX}}"/src
	doins -r "${S}"/doc/src/images || die "Installing images failed."

	qt4-build_src_install
}
