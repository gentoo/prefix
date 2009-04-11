# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/netdiscover/netdiscover-0.3_beta6-r1.ebuild,v 1.2 2008/07/11 17:58:56 armin76 Exp $

inherit eutils autotools

MY_PV="${PV/_/-}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="An active/passive address reconnaissance tool."
HOMEPAGE="http://nixgeneration.com/~jaime/netdiscover/"
SRC_URI="http://nixgeneration.com/~jaime/netdiscover/releases/${MY_P}.tar.gz
		mirror://gentoo/netdiscover-0.3-beta6-oui-db-update-20080330.patch.bz2"
IUSE=""

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

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${WORKDIR}"/netdiscover-0.3-beta6-oui-db-update-20080330.patch
	# Avoid installation of ChangeLog, LICENSE, etc. We do this ourselves.
	sed -i 's:netdiscoverdoc:noinst:' Makefile.am
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die "Make install failed."
	dodoc AUTHORS ChangeLog README TODO
}
