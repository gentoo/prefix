# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/hexedit/hexedit-1.2.10.ebuild,v 1.15 2007/02/11 13:10:51 vapier Exp $

EAPI="prefix"

DESCRIPTION="View and edit files in hex or ASCII"
HOMEPAGE="http://www.chez.com/prigaux/hexedit.html"
SRC_URI="http://merd.net/pixel/${P}.src.tgz"

LICENSE="GPL-1"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND="sys-libs/ncurses"
RDEPEND=""

S=${WORKDIR}/${PN}

src_install() {
	dobin hexedit || die "dobin failed"
	doman hexedit.1
	dodoc Changes TODO
}
