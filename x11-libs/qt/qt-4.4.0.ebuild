# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt/qt-4.4.0.ebuild,v 1.4 2008/05/30 04:38:21 jer Exp $

EAPI="prefix"

DESCRIPTION="The Qt toolkit is a comprehensive C++ application development framework."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( QPL-1.0 GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux"

IUSE="opengl qt3support"

DEPEND=""
RDEPEND=">=x11-libs/qt-gui-${PV}
	>=x11-libs/qt-svg-${PV}
	>=x11-libs/qt-test-${PV}
	>=x11-libs/qt-sql-${PV}
	>=x11-libs/qt-svg-${PV}
	>=x11-libs/qt-test-${PV}
	>=x11-libs/qt-assistant-${PV}
	>=x11-libs/qt-xmlpatterns-${PV}
	opengl? ( >=x11-libs/qt-opengl-${PV} )
	qt3support? ( >=x11-libs/qt-qt3support-${PV} )"
