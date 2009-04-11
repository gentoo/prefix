# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/ssldump/ssldump-0.9.ebuild,v 1.16 2008/02/06 21:12:19 grobian Exp $

inherit eutils

IUSE="ssl"

MY_P=${PN}-0.9b3
S=${WORKDIR}/${MY_P}
DESCRIPTION="A Tool for network monitoring and data acquisition"
SRC_URI="http://www.rtfm.com/ssldump/${MY_P}.tar.gz"
HOMEPAGE="http://www.rtfm.com/ssldump/"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
LICENSE="GPL-2"

DEPEND="net-libs/libpcap
	ssl? ( >=dev-libs/openssl-0.6.9 )"

src_unpack() {
	unpack ${A} ; cd ${S}

	epatch "${FILESDIR}/${P}"-libpcap-header.patch
	epatch "${FILESDIR}/${P}"-configure-dylib.patch
	epatch "${FILESDIR}/${P}"-openssl-0.9.8.compile-fix.patch
}

src_compile() {

	econf `use_with ssl crypto` || die
	emake || die
}

src_install() {
	into /usr
	dosbin ssldump
	doman ssldump.1
	dodoc COPYRIGHT CREDITS README FILES VERSION INSTALL ChangeLog
}
