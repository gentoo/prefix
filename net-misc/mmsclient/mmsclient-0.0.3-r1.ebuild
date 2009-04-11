# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/mmsclient/mmsclient-0.0.3-r1.ebuild,v 1.11 2008/02/03 15:40:35 grobian Exp $

inherit eutils

DESCRIPTION="mms protocol download utility"
HOMEPAGE="http://www.geocities.com/majormms/"
SRC_URI="http://www.geocities.com/majormms/mms_client-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

S=${WORKDIR}/mms_client-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PF}.patch
	epatch "${FILESDIR}"/${P}-fbsd.patch
}

src_install() {
	make DESTDIR="${D}" install || die
}
