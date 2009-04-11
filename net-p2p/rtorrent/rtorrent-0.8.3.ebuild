# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/rtorrent/rtorrent-0.8.3.ebuild,v 1.4 2009/03/01 19:52:19 loki_val Exp $

inherit base eutils toolchain-funcs flag-o-matic

DESCRIPTION="BitTorrent Client using libtorrent"
HOMEPAGE="http://libtorrent.rakshasa.no/"
SRC_URI="http://libtorrent.rakshasa.no/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug ipv6 xmlrpc"

RDEPEND=">=net-libs/libtorrent-0.12.${PV##*.}
	>=dev-libs/libsigc++-2
	>=net-misc/curl-7.18
	sys-libs/ncurses
	xmlrpc? ( dev-libs/xmlrpc-c )"
DEPEND="${RDEPEND}
        dev-util/pkgconfig"

PATCHES=( "${FILESDIR}/${PN}-0.8.2-gcc34.patch" )

src_compile() {
	replace-flags -Os -O2
	append-flags -fno-strict-aliasing

	if [[ $(tc-arch) = "x86" ]]; then
		filter-flags -fomit-frame-pointer -fforce-addr
	fi

	econf	$(use_enable debug) \
		$(use_enable ipv6) \
		$(use_with xmlrpc xmlrpc-c) \
		--disable-dependency-tracking \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS README TODO doc/rtorrent.rc
}

pkg_postinst() {
	elog "rtorrent now supports a configuration file."
	elog "A sample configuration file for rtorrent can be found"
	elog "in rtorrent.rc in ${EROOT}usr/share/doc/${PF}/"
	elog ""
	ewarn "If you're upgrading from rtorrent <0.8.0, you will have to delete your"
	ewarn "session directory or run the fixSession080-c.py script from this address:"
	ewarn "http://rssdler.googlecode.com/files/fixSession080-c.py"
	ewarn "See http://libtorrent.rakshasa.no/wiki/LibTorrentKnownIssues for more info."
}
