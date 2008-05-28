# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-xmlpatterns/qt-xmlpatterns-4.4.0.ebuild,v 1.4 2008/05/27 13:12:42 armin76 Exp $

EAPI="prefix"

inherit qt4-build

DESCRIPTION="The patternist module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( QPL-1.0 GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

DEPEND="~x11-libs/qt-core-${PV}"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="src/xmlpatterns tools/xmlpatterns"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}"
QCONFIG_ADD="xmlpatterns"
QCONFIG_DEFINE="QT_XMLPATTERNS"

src_compile() {
	local myconf
	myconf="${myconf} -xmlpatterns"

	qt4-build_src_compile
}
