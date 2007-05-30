# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libtorrent/libtorrent-0.11.4.ebuild,v 1.2 2007/05/24 15:44:46 drizzt Exp $

EAPI="prefix"

inherit eutils toolchain-funcs flag-o-matic libtool autotools

DESCRIPTION="LibTorrent is a BitTorrent library written in C++ for *nix."
HOMEPAGE="http://libtorrent.rakshasa.no/"
SRC_URI="http://libtorrent.rakshasa.no/downloads/${P}.tar.gz"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~x86-macos"

IUSE="debug"

RDEPEND=">=dev-libs/libsigc++-2"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.11"

#src_unpack() {
#	unpack ${A}
#	cd "${S}"

#	AT_M4DIR="scripts" eautoreconf
#}

src_compile() {
	replace-flags -Os -O2
	append-flags -fno-strict-aliasing

	if [[ $(tc-arch) = "x86" ]]; then
		filter-flags -fomit-frame-pointer -fforce-addr

		# See bug #151221. It seems only to hit on GCC 4.1 and x86 architecture
		# it could be safer to fallback to -O1, but with the high use of STL in
		# rtorrent, that could make it too slow.
		[[ $(gcc-major-version)$(gcc-minor-version) == "41" ]] && replace-flags -O2 -O3
	fi

	elibtoolize
	econf \
		$(use_enable debug) \
		--disable-dependency-tracking \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
}
