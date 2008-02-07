# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/xbiso/xbiso-0.6.1.ebuild,v 1.2 2006/02/01 23:04:58 metalgod Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Xbox xdvdfs ISO extraction utility"
HOMEPAGE="http://sourceforge.net/projects/xbiso/"
SRC_URI="mirror://sourceforge/xbiso/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

src_unpack() {
	unpack ${A}
}

src_install() {
	dobin xbiso || die "install failed"
	dodoc README CHANGELOG
}
