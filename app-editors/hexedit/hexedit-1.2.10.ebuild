# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/hexedit/hexedit-1.2.10.ebuild,v 1.17 2007/07/05 01:41:49 angelos Exp $

EAPI="prefix"

DESCRIPTION="View and edit files in hex or ASCII"
HOMEPAGE="http://people.mandriva.com/~prigaux/hexedit.html"
SRC_URI="http://people.mandriva.com/~prigaux/${P}.src.tgz"

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
