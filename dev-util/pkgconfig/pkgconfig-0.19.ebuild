# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/pkgconfig/pkgconfig-0.19.ebuild,v 1.1 2005/08/29 03:15:33 leonardop Exp $

EAPI="prefix"

inherit flag-o-matic

MY_PN="pkg-config"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="Package config system that manages compile/link flags"
HOMEPAGE="http://pkgconfig.freedesktop.org/wiki/"

PVP=(${PV//[-\._]/ })
SRC_URI="mirror://gnome/sources/${MY_PN}/${PVP[0]}.${PVP[1]}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="hardened"

DEPEND=""

S=${WORKDIR}/${MY_P}


src_unpack() {
	unpack "${A}"

	use ppc64 && use hardened && replace-flags -O[2-3] -O1
}

src_install() {
	make DESTDIR="${DEST}" install || die "Installation failed"

	dodoc AUTHORS ChangeLog NEWS README
	
}
