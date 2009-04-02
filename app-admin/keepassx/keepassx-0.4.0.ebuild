# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/keepassx/keepassx-0.4.0.ebuild,v 1.1 2009/03/31 02:17:44 tgurr Exp $

EAPI="prefix 2"

inherit eutils qt4

DESCRIPTION="Qt password manager compatible with its Win32 and Pocket PC versions."
HOMEPAGE="http://keepassx.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="debug pch"

DEPEND="x11-libs/qt-core:4[qt3support]
	x11-libs/qt-gui:4[qt3support]
	x11-libs/qt-xmlpatterns:4"
RDEPEND="${DEPEND}"

src_configure() {
	local conf_add
	use debug && conf_add="${conf_add} debug" || conf_add="${conf_add} release"
	use pch && conf_add="${conf_add} PRECOMPILED=1" || conf_add="${conf_add} PRECOMPILED=0"

	eqmake4 ${PN}.pro -recursive \
		PREFIX="${ED}/usr" \
		CONFIG+="${conf_add}" \
		|| die "eqmake4 failed."
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
