# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/bsign/bsign-0.4.5.ebuild,v 1.9 2008/12/30 17:50:04 angelos Exp $

inherit autotools toolchain-funcs

DESCRIPTION="embed secure hashes (SHA1) and digital signatures (GNU Privacy Guard) into files"
HOMEPAGE="http://packages.debian.org/sid/bsign"
SRC_URI="mirror://debian/pool/main/b/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-non-gnu.patch # for Darwin, BSD, Solaris, etc.
	[[ ${CHOST} == *-darwin* ]] && sed -i -e '/^LFLAGS/s/-static//' Makefile.in

	sed -i -e "/^CFLAGS/d" \
		-e "/^CXXFLAGS/d" configure.in
	eautoreconf
}

src_install() {
	dobin bsign_sign bsign_verify bsign_hash bsign_check || die
	newbin o/bsign-unstripped bsign || die
	doman bsign.1
	dodoc README
}
