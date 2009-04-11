# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libtorrent/libtorrent-0.12.3-r2.ebuild,v 1.1 2008/11/02 15:35:55 loki_val Exp $

inherit base eutils toolchain-funcs flag-o-matic libtool

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

PATCHES=(	"${FILESDIR}/${P}-fix-epoll-crash.patch"
		"${FILESDIR}/${P}-fix-poll_fd.patch"
		"${FILESDIR}/${P}-fix-fill_read_buffer-overflow.patch" )

src_unpack() {
	base_src_unpack
	cd "${S}"
	elibtoolize #Don't remove. Needed for *bsd.
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
