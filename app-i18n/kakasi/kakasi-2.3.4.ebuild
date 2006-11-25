# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/kakasi/kakasi-2.3.4.ebuild,v 1.13 2006/07/12 21:09:14 agriffis Exp $

EAPI="prefix"

inherit autotools

DESCRIPTION="Converts Japanese text between kanji, kana, and romaji"
HOMEPAGE="http://kakasi.namazu.org/"
SRC_URI="http://kakasi.namazu.org/stable/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

DEPEND="virtual/libc"

src_unpack() {
	unpack ${A}

	# The shipped configure sets -undefined suppress, but this is
	# resulting in an error of the linker, because we're not in two
	# level namespace.  However, we don't need to suppress undefined
	# errors, because there aren't any.  Autoreconfing solves this.
	cd "${S}"
	eautoreconf
}

src_install() {
	make DESTDIR=${D} install || die
	doman doc/kakasi.1
	dodoc AUTHORS ChangeLog NEWS ONEWS README README-ja THANKS TODO
	dodoc doc/ChangeLog.lib doc/JISYO doc/README.lib README.wakati
}
