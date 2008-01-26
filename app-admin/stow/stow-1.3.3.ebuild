# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/stow/stow-1.3.3.ebuild,v 1.24 2005/03/10 01:44:59 j4rg0n Exp $

EAPI="prefix"

DESCRIPTION="manage installation of software in /usr/local"
SRC_URI="mirror://gnu/stow/${P}.tar.gz"
HOMEPAGE="http://www.gnu.org/software/${PN}/"

SLOT="0"
LICENSE="GPL-2"
IUSE=""
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

DEPEND="dev-lang/perl"

src_compile() {
	econf || die
	emake || die "emake failed"
}

src_install() {
	make DESTDIR=${D} install || die "make install failed"
}
