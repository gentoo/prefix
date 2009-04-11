# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-dbus/qt-dbus-4.4.2.ebuild,v 1.9 2009/02/18 19:50:37 jer Exp $

EAPI=1
inherit qt4-build

DESCRIPTION="The DBus module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

# depend on gui instead of core.  There's a GUI based viewer that's built, and since it's a desktop
# protocol I don't know if there's value trying to derive it out into a core build
# The library itself, however, only depends on core and xml
DEPEND="~x11-libs/qt-core-${PV}
	>=sys-apps/dbus-1.0.2
	!<=x11-libs/qt-4.4.0_alpha:${SLOT}"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="
src/dbus
tools/qdbus/qdbus
tools/qdbus/qdbusxml2cpp
tools/qdbus/qdbuscpp2xml"
QCONFIG_ADD="dbus dbus-linked"
QCONFIG_DEFINE="QT_DBUS"

#FIXME: Check if these are still needed with the header package
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
include/Qt/
include/QtCore/
include/QtDBus/
src/corelib/global/
src/corelib/io/
src/corelib/kernel/
src/corelib/thread/
src/corelib/tools/
"

src_compile() {
	local myconf
	myconf="${myconf} -dbus-linked"

	qt4-build_src_compile
}
