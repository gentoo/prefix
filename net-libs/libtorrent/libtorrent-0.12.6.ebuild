# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libtorrent/libtorrent-0.12.6.ebuild,v 1.5 2010/05/04 10:12:20 angelos Exp $

EAPI=2
inherit eutils libtool

DESCRIPTION="LibTorrent is a BitTorrent library written in C++ for *nix."
HOMEPAGE="http://libtorrent.rakshasa.no/"
SRC_URI="http://libtorrent.rakshasa.no/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris"
IUSE="debug ipv6 ssl"

RDEPEND=">=dev-libs/libsigc++-2.2.2:2
	ssl? ( dev-libs/openssl )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"


src_prepare() {
	epatch "${FILESDIR}"/${P}-gcc44.patch
	epatch "${FILESDIR}"/${PN}-0.12.5-solaris-madvise.patch
	elibtoolize
}

src_configure() {
	# need this, or configure script bombs out on some null shift, bug #291229
	export CONFIG_SHELL=${BASH}

	econf \
		--disable-dependency-tracking \
		--enable-aligned \
		$(use_enable debug) \
		$(use_enable ipv6) \
		$(use_enable ssl openssl) \
		$(use kernel_linux && echo --with-posix-fallocate)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS NEWS README
}
