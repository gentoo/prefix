# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/rtorrent/rtorrent-0.8.2-r3.ebuild,v 1.1 2008/06/28 11:35:00 loki_val Exp $

EAPI="prefix"

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="BitTorrent Client using libtorrent"
HOMEPAGE="http://libtorrent.rakshasa.no/"
SRC_URI="http://libtorrent.rakshasa.no/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug ipv6 xmlrpc"

DEPEND=">=net-libs/libtorrent-0.12.${PV##*.}
	>=dev-libs/libsigc++-2
	>=net-misc/curl-7.18
	sys-libs/ncurses
	xmlrpc? ( dev-libs/xmlrpc-c )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.8.0+gcc-4.3.patch
	epatch "${FILESDIR}"/${P}-fix_start_stop_filter.patch
	epatch "${FILESDIR}"/${P}-fix_conn_type_seed.patch
	epatch "${FILESDIR}"/${P}-fix_load_cache.patch
}

src_compile() {
	replace-flags -Os -O2
	append-flags -fno-strict-aliasing

	if [[ $(tc-arch) = "x86" ]]; then
		filter-flags -fomit-frame-pointer -fforce-addr
	fi

	econf \
		$(use_enable debug) \
		$(use_enable ipv6) \
		$(use_with xmlrpc xmlrpc-c) \
		--disable-dependency-tracking \
		--enable-aligned \
		|| die "econf failed"

	emake || die "emake failed"
}

pkg_postinst() {
	elog "rtorrent now supports a configuration file."
	elog "A sample configuration file for rtorrent can be found"
	elog "in ${EROOT}usr/share/doc/${PF}/rtorrent.rc.gz."
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS README TODO doc/rtorrent.rc
}
