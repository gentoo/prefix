# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/chaosreader/chaosreader-0.94.ebuild,v 1.5 2006/12/24 16:10:29 spock Exp $

inherit eutils prefix

DESCRIPTION="A tool to trace TCP/UDP/... sessions and fetch application data from snoop or tcpdump logs."
HOMEPAGE="http://users.tpg.com.au/bdgcvb/chaosreader.html"
SRC_URI="http://dev.gentoo.org/~spock/portage/distfiles/${P}.bz2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
LICENSE="GPL-2"
IUSE=""
DEPEND=">=dev-lang/perl-5.8.0"
S=${WORKDIR}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/chaosreader-0.94-zombies.patch
	epatch ${FILESDIR}/chaosreader-0.94-prefix.patch
	eprefixify chaosreader-0.94
}

src_install() {
	newbin ${S}/${P} chaosreader
}
