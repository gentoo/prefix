# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/tinc/tinc-1.0.7.ebuild,v 1.1 2007/04/19 08:45:08 dragonheart Exp $

EAPI="prefix"

DESCRIPTION="tinc is an easy to configure VPN implementation"
HOMEPAGE="http://www.tinc-vpn.org/"
SRC_URI="http://www.tinc-vpn.org/packages/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-macos ~x86 ~x86-macos"
IUSE="nls"

DEPEND=">=dev-libs/openssl-0.9.7c
	kernel_Linux? ( virtual/linux-sources )
	>=dev-libs/lzo-2
	>=sys-libs/zlib-1.1.4-r2
	nls? ( sys-devel/gettext )"

src_compile() {
	econf --enable-jumbograms $(use_enable nls) || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS NEWS README THANKS
	doinitd "${FILESDIR}"/tincd
}

pkg_postinst() {
	elog "This package requires the tun/tap kernel device."
	elog "Look at http://www.tinc-vpn.org/ for how to configure tinc"
}
