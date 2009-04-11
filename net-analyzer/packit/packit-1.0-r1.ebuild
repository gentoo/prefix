# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/packit/packit-1.0-r1.ebuild,v 1.2 2008/02/06 21:07:29 grobian Exp $

inherit eutils

DESCRIPTION="network auditing tool that allows you to monitor, manipulate, and inject customized IPv4 traffic"
HOMEPAGE="http://www.packetfactory.net/projects/packit/"
SRC_URI="http://www.packetfactory.net/projects/packit/downloads/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=">=net-libs/libnet-1.1.2
	net-libs/libpcap"

src_unpack(){
	unpack ${A}
	cd "${S}"
	sed -i 's:net/bpf.h:pcap-bpf.h:g' "${S}"/src/{globals.h,main.h}
	epatch "${FILESDIR}/packit-1.0-noopt.patch"
	epatch "${FILESDIR}/packit-1.0-nostrip.patch"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc VERSION docs/*
}
