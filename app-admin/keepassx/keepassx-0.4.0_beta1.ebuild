# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/keepassx/keepassx-0.4.0_beta1.ebuild,v 1.1 2009/02/28 19:44:44 tgurr Exp $

EAPI="prefix 2"

inherit eutils qt4 versionator

MY_PV=$(delete_version_separator 3)

DESCRIPTION="Qt password manager compatible with its Win32 and Pocket PC versions."
HOMEPAGE="http://keepassx.sourceforge.net/"
SRC_URI="http://www.keepassx.org/download/KeePassX-${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="debug pch"
DEPEND="|| ( ( x11-libs/qt-core:4[qt3support]
			x11-libs/qt-gui:4[qt3support]
			x11-libs/qt-xmlpatterns:4 )
		( =x11-libs/qt-4.3*:4[png,qt3support,zlib] ) )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${MY_PV}"

src_configure() {
	local conf_add
	use debug && conf_add="${conf_add} debug" || conf_add="${conf_add} release"
	use pch && conf_add="${conf_add} PRECOMPILED=1" || conf_add="${conf_add} PRECOMPILED=0"

	eqmake4 ${PN}.pro -recursive \
		PREFIX="${ED}/usr" \
		CONFIG+="${conf_add}" \
		|| die "eqmake4 failed."
}

src_compile(){
	# workaround compile failure due to distcc, bug #214327
	PATH=${PATH/\/usr\/lib\/distcc\/bin:}
	emake || die "emake failed"
}

src_install(){
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc changelog || die "dodoc failed"
}
