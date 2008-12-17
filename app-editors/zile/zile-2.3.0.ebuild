# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/zile/zile-2.3.0.ebuild,v 1.1 2008/12/16 11:39:33 ulm Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Zile is a small Emacs clone"
HOMEPAGE="http://www.gnu.org/software/zile/"
SRC_URI="mirror://gnu/zile/${P}.tar.gz"

LICENSE="GPL-3 FDL-1.2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="sys-libs/ncurses
	>=sys-apps/texinfo-4.3"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-splash.patch"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS BUGS NEWS README THANKS || die "dodoc failed"

	rm ${ED}/usr/lib/charset.alias
}
