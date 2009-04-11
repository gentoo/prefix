# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/tinc/tinc-1.0.9.ebuild,v 1.1 2009/01/04 07:15:08 dragonheart Exp $

DESCRIPTION="tinc is an easy to configure VPN implementation"
HOMEPAGE="http://www.tinc-vpn.org/"
SRC_URI="http://www.tinc-vpn.org/packages/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"
IUSE="nls kernel_linux"

DEPEND=">=dev-libs/openssl-0.9.7c
	kernel_linux? ( virtual/linux-sources )
	>=dev-libs/lzo-2
	>=sys-libs/zlib-1.1.4-r2
	nls? ( sys-devel/gettext )"

src_compile() {
	econf --enable-jumbograms $(use_enable nls)
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodir /etc/tinc
	dodoc AUTHORS NEWS README THANKS
	doinitd "${FILESDIR}"/tincd
	doconfd "${FILESDIR}"/tinc.networks
}

pkg_postinst() {
	elog "This package requires the tun/tap kernel device."
	elog "Look at http://www.tinc-vpn.org/ for how to configure tinc"
}
