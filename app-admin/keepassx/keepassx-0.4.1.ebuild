# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/keepassx/keepassx-0.4.1.ebuild,v 1.3 2009/11/17 22:35:37 spatz Exp $

EAPI=2

inherit eutils qt4

DESCRIPTION="Qt password manager compatible with its Win32 and Pocket PC versions."
HOMEPAGE="http://keepassx.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="debug pch"

DEPEND="x11-libs/qt-core:4
	x11-libs/qt-gui:4
	x11-libs/qt-xmlpatterns:4"
RDEPEND="${DEPEND}"

src_configure() {
	local conf_pch
	use pch && conf_pch="PRECOMPILED=1" || conf_pch="PRECOMPILED=0"

	eqmake4 ${PN}.pro -recursive \
		PREFIX="${ED}/usr" \
		"${conf_pch}"
}

src_compile() {
	# workaround compile failure due to distcc, bug #214327
	PATH=${PATH/\/usr\/lib\/distcc\/bin:}
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc changelog || die "dodoc failed"
}
