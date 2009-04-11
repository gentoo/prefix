# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/rej/rej-0.16.ebuild,v 1.6 2009/01/12 04:03:24 jer Exp $

DESCRIPTION="A utility for solving diff/patch rejects"
HOMEPAGE="http://ftp.suse.com/pub/people/mason/rej/"
SRC_URI="http://ftp.suse.com/pub/people/mason/rej/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""
RDEPEND="
	dev-lang/perl
	!<app-editors/mp-5
	!dev-lang/qu-prolog
	!dev-util/mpatch
	"

src_compile() {
	echo
}

src_install() {
	sed -i -e '1c\#!'"${EPREFIX}"'/usr/bin/perl' rej qp mp
	dobin rej qp mp
	dodoc CHANGELOG README vimrc
}
