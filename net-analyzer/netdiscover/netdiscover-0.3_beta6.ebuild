# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/netdiscover/netdiscover-0.3_beta6.ebuild,v 1.1 2006/07/19 00:33:31 vanquirius Exp $

MY_PV="${PV/_/-}"
MY_P="${PN}-${MY_PV}"

IUSE=""

DESCRIPTION="An active/passive address reconnaissance tool."
HOMEPAGE="http://nixgeneration.com/~jaime/netdiscover/"
SRC_URI="http://nixgeneration.com/~jaime/netdiscover/releases/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

DEPEND=">=net-libs/libnet-1.1.2.1-r1
	>=net-libs/libpcap-0.8.3-r1"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	# don't ask the user for questions/input/interaction
	sed -i -e 's:read NONE::g' configure
}

src_install()
{
	dobin src/netdiscover
	dodoc AUTHORS README TODO
}
