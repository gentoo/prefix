# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/rtorrent/rtorrent-0.7.8.ebuild,v 1.5 2007/11/10 21:52:28 corsair Exp $

EAPI="prefix"

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="BitTorrent Client using libtorrent"
HOMEPAGE="http://libtorrent.rakshasa.no/"
SRC_URI="http://libtorrent.rakshasa.no/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE="debug"

RDEPEND=">=net-libs/libtorrent-0.11.${PV##*.}
	>=dev-libs/libsigc++-2.0
	>=net-misc/curl-7.15
	sys-libs/ncurses"
DEPEND="${RDEPEND}"

src_compile() {
	replace-flags -Os -O2
	append-flags -fno-strict-aliasing

	if [[ $(tc-arch) = "x86" ]]; then
		filter-flags -fomit-frame-pointer -fforce-addr
	fi

	econf \
		$(use_enable debug) \
		--disable-xmlrpc-c \
		--disable-dependency-tracking \
		|| die "econf failed"
	# --disable-xmlrpc-c: I want to keep it disabled while >=dev-libs/xmlrpc-c-1.07 is masked

	emake || die "emake failed"
}

pkg_postinst() {
	elog "rtorrent now supports a configuration file."
	elog "A sample configuration file for rtorrent is can be found"
	elog "in ${EROOT}usr/share/doc/${PF}/rtorrent.rc.gz."
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS README TODO doc/rtorrent.rc
}
