# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/hexedit/hexedit-1.2.12.ebuild,v 1.5 2007/08/13 20:04:10 dertobi123 Exp $

EAPI="prefix"

DESCRIPTION="View and edit files in hex or ASCII"
HOMEPAGE="http://people.mandriva.com/~prigaux/hexedit.html"
SRC_URI="http://people.mandriva.com/~prigaux/${P}.src.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE=""

DEPEND="sys-libs/ncurses"
RDEPEND=""

S=${WORKDIR}/${PN}

src_install() {
	dobin hexedit || die "dobin failed"
	doman hexedit.1
	dodoc Changes TODO
}
