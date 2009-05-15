# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-webkit/qt-webkit-4.5.1.ebuild,v 1.2 2009/05/13 18:06:05 ranger Exp $

EAPI=2
inherit qt4-build

DESCRIPTION="The Webkit module for the Qt toolkit"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="~x11-libs/qt-core-${PV}[debug=,ssl]
	~x11-libs/qt-gui-${PV}[debug=]
	|| ( ~x11-libs/qt-phonon-${PV}:${SLOT}[debug=] media-sound/phonon )"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="src/3rdparty/webkit/WebCore tools/designer/src/plugins/qwebview"
QT4_EXTRACT_DIRECTORIES="
include/
src/
tools/"
QCONFIG_ADD="webkit"
QCONFIG_DEFINE="QT_WEBKIT"

src_prepare() {
	[[ $(tc-arch) == "ppc64" ]] && append-flags -mminimal-toc #241900
	qt4-build_src_prepare
}

src_configure() {
	myconf="${myconf} -webkit"
	qt4-build_src_configure
}
