# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/aesutil/aesutil-1.0.7.ebuild,v 1.6 2009/01/03 17:57:52 angelos Exp $

inherit toolchain-funcs

MY_P="${PN/util/}-${PV}"
DESCRIPTION="Command line program ('aes') to encrypt and decrypt data using the Rijndael algorithm"
HOMEPAGE="http://my.cubic.ch/users/timtas/aes/"
SRC_URI="http://my.cubic.ch/users/timtas/aes/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -e "/^CFLAGS/s:-g -Wall:${CFLAGS}:" Makefile.linux > Makefile
	sed -i -e "/^LDFLAGS/s:-g:${LDFLAGS}:" Makefile
}

src_compile() {
	emake CC="$(tc-getCC)" || die
}

src_install() {
	dobin aes || die
	dodoc CHANGES INSTALL README TODO
}
