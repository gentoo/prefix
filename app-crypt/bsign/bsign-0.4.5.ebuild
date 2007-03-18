# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/bsign/bsign-0.4.5.ebuild,v 1.7 2005/01/01 12:26:14 eradicator Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="embed secure hashes (SHA1) and digital signatures (GNU Privacy Guard) into files"
HOMEPAGE="http://packages.debian.org/unstable/admin/bsign.html"
SRC_URI="mirror://debian/pool/main/b/bsign/${PN}_${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-macos ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-non-gnu.patch # for Darwin, BSD, Solaris, etc.
	[[ ${CHOST} == *-darwin* ]] && sed -i -e '/^LFLAGS/s/-static//' Makefile.in
}

src_install() {
	dobin bsign bsign_sign bsign_verify bsign_hash bsign_check || die
	doman bsign.1
}
