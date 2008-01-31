# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/mmv/mmv-1.01b_p14.ebuild,v 1.2 2008/01/30 10:04:31 cla Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Move/copy/append/link multiple files according to a set of wildcard patterns."
HOMEPAGE="http://packages.debian.org/unstable/utils/mmv"

DEB_PATCH_VER=${PV#*_p}
MY_VER=${PV%_p*}

SRC_URI="mirror://debian/pool/main/m/mmv/${PN}_${MY_VER}.orig.tar.gz
	mirror://debian/pool/main/m/mmv/${PN}_${MY_VER}-${DEB_PATCH_VER}.diff.gz"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

S=${WORKDIR}/${PN}-${MY_VER}.orig

src_unpack() {
	unpack ${PN}_${MY_VER}.orig.tar.gz
	epatch "${DISTDIR}"/${PN}_${MY_VER}-${DEB_PATCH_VER}.diff.gz
}

src_compile() {
	mmv_CFLAGS=" -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
	emake CC="$(tc-getCC)" CFLAGS="${mmv_CFLAGS} ${CFLAGS}" LDFLAGS="${LDFLAGS}" || die
}

src_install() {
	dobin mmv
	dosym /usr/bin/mmv /usr/bin/mcp
	dosym /usr/bin/mmv /usr/bin/mln
	dosym /usr/bin/mmv /usr/bin/mad

	doman mmv.1
	dosym mmv.1.gz /usr/share/man/man1/mcp.1.gz
	dosym mmv.1.gz /usr/share/man/man1/mln.1.gz
	dosym mmv.1.gz /usr/share/man/man1/mad.1.gz

	dodoc ANNOUNCE debian/{changelog,control,copyright}
}
