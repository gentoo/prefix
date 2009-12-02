# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-ftp/tnftp/tnftp-20090606.ebuild,v 1.1 2009/11/22 21:52:48 swegener Exp $

EAPI="2"

inherit eutils

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

src_prepare() {
	epatch "${FILESDIR}"/${P}-glibc-2.8-ARG_MAX.patch
	epatch "${FILESDIR}"/${P}-getline.patch
}

src_configure() {
	econf \
		--enable-editcomplete \
		$(use_enable ipv6) \
		$(use_with socks5 socks) \
		|| die "econf failed"
}

src_install() {
	newbin src/ftp tnftp || die "newbin failed"
	newman src/ftp.1 tnftp.1 || die "newman failed"
	dodoc ChangeLog README THANKS || die "dodoc failed"
}
