# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/throttle/throttle-1.2.ebuild,v 1.4 2008/12/08 00:35:42 darkside Exp $

DESCRIPTION="Bandwidth limiting pipe"
HOMEPAGE="http://klicman.org/throttle/"
SRC_URI="http://klicman.org/throttle/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ppc-macos ~x86-macos"
IUSE=""

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS NEWS README ChangeLog
}
