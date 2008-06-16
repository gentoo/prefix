# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-ftp/tnftp/tnftp-20070806.ebuild,v 1.7 2008/06/15 18:39:45 swegener Exp $

EAPI="prefix"

WANT_AUTOCONF="2.5"
WANT_AUTOMAKE="none"

inherit eutils autotools

DESCRIPTION="NetBSD FTP client with several advanced features"
SRC_URI="ftp://ftp.netbsd.org/pub/NetBSD/misc/${PN}/${P}.tar.gz
	ftp://ftp.netbsd.org/pub/NetBSD/misc/${PN}/old/${P}.tar.gz"
HOMEPAGE="ftp://ftp.netbsd.org/pub/NetBSD/misc/tnftp/"

SLOT="0"
LICENSE="as-is"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="ipv6 socks5"

DEPEND=">=sys-libs/ncurses-5.1
	socks5? ( net-proxy/dante )"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-libedit.patch
	epatch "${FILESDIR}"/${P}-glibc-2.8-ARG_MAX.patch

	eautoconf
}

src_compile() {
	econf \
		--enable-editcomplete \
		$(use_enable ipv6) \
		$(use_with socks5 socks) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	newbin src/ftp tnftp || die "newbin failed"
	newman src/ftp.1 tnftp.1 || die "newman failed"
	dodoc ChangeLog README THANKS || die "dodoc failed"
}
