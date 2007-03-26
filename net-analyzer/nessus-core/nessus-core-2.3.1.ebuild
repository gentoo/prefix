# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/nessus-core/nessus-core-2.3.1.ebuild,v 1.9 2007/02/01 19:59:35 jokey Exp $

EAPI="prefix"

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="A remote security scanner for Linux (nessus-core)"
HOMEPAGE="http://www.nessus.org/"
SRC_URI="ftp://ftp.nessus.org/pub/nessus/experimental/nessus-${PV}/src/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="tcpd gtk debug prelude"

DEPEND="~net-analyzer/nessus-libraries-${PV}
	~net-analyzer/libnasl-${PV}
	tcpd? ( sys-apps/tcp-wrappers )
	gtk? ( =x11-libs/gtk+-2* )
	prelude? ( dev-libs/libprelude )
	!net-analyzer/nessus-client"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}/${P}-gcc4.diff"
}

src_compile() {
	export CC="$(tc-getCC)"
	[[ ${CHOST} == *-darwin* ]] && append-ldflags -lintl
	econf \
		$(use_enable tcpd tcpwrappers) \
		$(use_enable debug) \
		$(use_enable gtk) \
		|| die "configure failed"
	emake -j1 || die "emake failed"

}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	# net-analyzer/nessus-libraries provides includes.h
	rm -f "${ED}"/usr/include/nessus/includes.h

	dodoc README* UPGRADE_README CHANGES
	dodoc doc/*.txt doc/ntp/*

	newinitd "${FILESDIR}"/nessusd-r8 nessusd || die "newinitd failed"
	keepdir /var/lib/nessus/logs
	keepdir /var/lib/nessus/users
}
