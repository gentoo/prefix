# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt/qt-4.4.2.ebuild,v 1.8 2009/02/11 10:05:08 hwoarang Exp $

EAPI="prefix"

DESCRIPTION="The Qt toolkit is a comprehensive C++ application development framework."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"

IUSE="dbus opengl qt3support"

DEPEND=""
RDEPEND="~x11-libs/qt-gui-${PV}
	~x11-libs/qt-svg-${PV}
	~x11-libs/qt-test-${PV}
	~x11-libs/qt-sql-${PV}
	~x11-libs/qt-script-${PV}
	~x11-libs/qt-assistant-${PV}
	~x11-libs/qt-xmlpatterns-${PV}
	!sparc? ( !alpha? ( !ia64? ( !x86-fbsd? ( ~x11-libs/qt-webkit-${PV} ) ) ) )
	dbus? ( ~x11-libs/qt-dbus-${PV} )
	opengl? ( ~x11-libs/qt-opengl-${PV} )
	qt3support? ( ~x11-libs/qt-qt3support-${PV} )"
