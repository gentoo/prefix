# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/dnswalk/dnswalk-2.0.2.ebuild,v 1.16 2007/07/16 14:43:35 armin76 Exp $

S=${WORKDIR}
DESCRIPTION="dnswalk is a DNS database debugger"
SRC_URI="mirror://sourceforge/dnswalk/${P}.tar.gz"
HOMEPAGE="http://sourceforge.net/projects/dnswalk/"

DEPEND=">=dev-perl/Net-DNS-0.12"

SLOT="0"
LICENSE="as-is"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

src_compile() {
	sed -i 's:#!/usr/contrib/bin/perl:#!'"${EPREFIX}"'/usr/bin/perl:' dnswalk
}

src_install () {
	dobin dnswalk

	dodoc CHANGES README TODO \
		do-dnswalk makereports sendreports rfc1912.txt dnswalk.errors
	doman dnswalk.1
}
