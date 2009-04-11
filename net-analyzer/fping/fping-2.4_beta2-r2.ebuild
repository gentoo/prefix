# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/fping/fping-2.4_beta2-r2.ebuild,v 1.8 2009/02/04 21:08:49 armin76 Exp $

DESCRIPTION="A utility to ping multiple hosts at once"
SRC_URI="http://www.fping.com/download/fping-2.4b2_to.tar.gz"
HOMEPAGE="http://www.fping.com/"

SLOT="0"
LICENSE="fping"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

S=${WORKDIR}/fping-2.4b2_to

src_install () {
	dosbin fping || die "Failed to install fping."
	fperms 4555 /usr/sbin/fping #241930
	doman fping.8
	dodoc ChangeLog README
}
