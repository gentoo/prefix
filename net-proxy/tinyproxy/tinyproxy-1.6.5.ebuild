# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-proxy/tinyproxy/tinyproxy-1.6.5.ebuild,v 1.1 2009/11/29 09:58:56 mrness Exp $

EAPI="2"

inherit eutils

DESCRIPTION="A lightweight HTTP/SSL proxy"
HOMEPAGE="http://www.banu.com/tinyproxy/"
SRC_URI="http://www.banu.com/pub/tinyproxy/1.6/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ppc-macos ~sparc-solaris"
IUSE="debug socks5 +http-via-header transparent-proxy"

DEPEND="socks5? ( net-proxy/dante )"
RDEPEND="${DEPEND}"

src_prepare() {
	use http-via-header || epatch "${FILESDIR}"/${PN}-no-via.patch
}

src_configure() {
	econf \
		--enable-xtinyproxy \
		--enable-filter \
		--enable-upstream \
		`use_enable transparent-proxy` \
		`use_enable debug` \
		`use_enable debug profiling` \
		`use_enable socks5 socks` \
		|| die "econf failed"
}

src_install() {
	sed -i \
		-e 's:mkdir $(datadir)/tinyproxy:mkdir -p $(DESTDIR)$(datadir)/tinyproxy:' \
		Makefile
	make DESTDIR="${D}" install || die "install failed"

	dodoc AUTHORS ChangeLog NEWS README TODO
	mv "${ED}/usr/share/tinyproxy" "${ED}/usr/share/doc/${PF}/html"

	newinitd "${FILESDIR}/tinyproxy.initd" tinyproxy
}

pkg_postinst() {
	einfo "For filtering domains and URLs, enable filter option in the configuration file"
	einfo "and add them to the filter file (one domain or URL per line)."
}
