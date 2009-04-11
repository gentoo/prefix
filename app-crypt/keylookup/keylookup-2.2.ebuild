# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/keylookup/keylookup-2.2.ebuild,v 1.13 2008/02/04 18:49:40 grobian Exp $

DESCRIPTION="A tool to fetch PGP keys from keyservers"
HOMEPAGE="http://www.palfrader.org/keylookup/"
SRC_URI="http://www.palfrader.org/keylookup/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND="dev-lang/perl
	app-crypt/gnupg"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e '1c\#!'"${EPREFIX}"'/usr/bin/perl -Tw' keylookup
}

src_install() {
	dobin keylookup || die
	doman keylookup.1
	dodoc ChangeLog NEWS TODO
}
