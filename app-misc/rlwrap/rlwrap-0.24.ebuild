# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/rlwrap/rlwrap-0.24.ebuild,v 1.7 2008/03/26 17:20:42 armin76 Exp $

EAPI="prefix"

DESCRIPTION="a 'readline wrapper' which uses the GNU readline lib to allow the editing of keyboard input for any command"
HOMEPAGE="http://utopia.knoware.nl/~hlub/uck/rlwrap"
SRC_URI="http://utopia.knoware.nl/~hlub/uck/rlwrap/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug"

DEPEND="sys-libs/readline"

src_compile() {
	econf $(use_enable debug)
	emake || die "emake failed."
}

src_install() {
	einstall || die "einstall failed."
	dodoc AUTHORS BUGS ChangeLog NEWS README
}
