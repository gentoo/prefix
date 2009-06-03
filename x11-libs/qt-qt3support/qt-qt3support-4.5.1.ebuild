# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-qt3support/qt-qt3support-4.5.1.ebuild,v 1.8 2009/06/02 18:01:49 fauli Exp $

EAPI=2
inherit qt4-build

DESCRIPTION="The Qt3 support module for the Qt toolkit"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="+accessibility phonon"

DEPEND="~x11-libs/qt-core-${PV}[debug=,qt3support]
	~x11-libs/qt-gui-${PV}[accessibility=,debug=,qt3support]
	~x11-libs/qt-sql-${PV}[debug=,qt3support]
	phonon? ( || ( ~x11-libs/qt-phonon-${PV}[debug=]
		media-sound/phonon[gstreamer] ) )"
#		kde? ( media-sound/phonon ) )"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="
src/qt3support
src/tools/uic3
tools/designer/src/plugins/widgets
tools/porting"

# mac version does not contain qtconfig?
if [[ ${CHOST} != *-darwin* ]]; then
	QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} tools/qtconfig"
fi

QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
src/
include/
tools/"

src_configure() {
	myconf="${myconf} -qt3support
		$(qt_use phonon gstreamer)
		$(qt_use phonon)
		$(qt_use accessibility)"
	qt4-build_src_configure
}
