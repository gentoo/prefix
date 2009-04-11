# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libtorrent/libtorrent-0.12.2-r3.ebuild,v 1.6 2008/08/25 20:19:48 jer Exp $

inherit autotools eutils toolchain-funcs flag-o-matic libtool

DESCRIPTION="LibTorrent is a BitTorrent library written in C++ for *nix."
HOMEPAGE="http://libtorrent.rakshasa.no/"
SRC_URI="http://libtorrent.rakshasa.no/downloads/${P}.tar.gz"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"

IUSE="debug ipv6"

RDEPEND=">=dev-libs/libsigc++-2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.11.9+gcc-4.3.patch
	epatch "${FILESDIR}"/${P}-dht_bounds_fix.patch
	epatch "${FILESDIR}"/${P}-fix_cull.patch
	epatch "${FILESDIR}"/${P}-fix_dht_target.patch
	epatch "${FILESDIR}"/${P}-fix_have_timer.patch
	epatch "${FILESDIR}"/${P}-fix_pex_leak.patch
	epatch "${FILESDIR}"/${P}-fix_write_datagram.patch
	epatch "${FILESDIR}"/${P}-lt-ver.patch
	epatch "${FILESDIR}"/${P}-tracker_timer_fix.patch

	elibtoolize #Don't remove
	eautoreconf
}

src_compile() {
	replace-flags -Os -O2

	if [[ $(tc-arch) = "x86" ]]; then
		filter-flags -fomit-frame-pointer -fforce-addr
	fi

	econf \
		$(use_enable debug) \
		$(use_enable ipv6) \
		--enable-aligned \
		--enable-static \
		--enable-shared \
		--disable-dependency-tracking \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS NEWS README
}
