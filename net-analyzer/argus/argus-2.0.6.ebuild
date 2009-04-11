# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/argus/argus-2.0.6.ebuild,v 1.5 2008/11/21 12:45:05 flameeyes Exp $

inherit eutils

DESCRIPTION="network Audit Record Generation and Utilization System"
HOMEPAGE="http://www.qosient.com/argus/"
SRC_URI="ftp://ftp.qosient.com/pub/argus/src/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
RDEPEND="virtual/libc
	net-libs/libpcap"

DEPEND="${RDEPEND}
	>=sys-devel/bison-1.28
	>=sys-devel/flex-2.4.6"

src_unpack() {
	unpack ${A} ; cd "${S}"

	epatch "${FILESDIR}"/${PN}-2.0.6-libpcap-include.patch

	# Fix hardcoded config file
	epatch "${FILESDIR}"/${PN}-2.0.5-gentoo.diff
}

src_install () {
	dodoc ChangeLog CREDITS README doc/{FAQ,HOW-TO,CHANGES}

	#do not install man/man1/tcpdump.1, file collision
	doman man/man5/* man/man8/*

	dolib lib/argus_common.a lib/argus_parse.a || die "dolib failed"

	if [[ ${CHOST} == *-darwin* ]]; then
		newsbin bin/argus_bpf argus || die "newsbin failed"
	else
		newsbin bin/argus_linux argus || die "newsbin failed"
	fi

	insinto /etc/argus
	doins support/Config/argus.conf

	newinitd "${FILESDIR}"/argus.initd argus
}

pkg_postinst() {
	elog "Please note that argus-clients has been split up from this"
	elog "package by upstream as of 2.0.6. If you want it, please emerge"
	elog "net-analyzer/argus-clients."

	elog "Also, you might want to edit /etc/argus/argus.conf before"
	elog "running argus."
}
