# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-arcade/nibbles/nibbles-0.0.4.ebuild,v 1.9 2007/04/24 14:51:25 drizzt Exp $

EAPI="prefix"

inherit games

MY_P=${PN}-v${PV}
DESCRIPTION="An ncurses-based Nibbles clone"
HOMEPAGE="http://www.earth.li/projectpurple/progs/nibbles.html"
SRC_URI="http://www.earth.li/projectpurple/files/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-fbsd ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="sys-libs/ncurses"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i \
		-e "s#/usr/local/games/nibbles.levels#${GAMES_DATADIR}/${PN}#" \
		nibbles.h \
		|| die "sed failed"

	sed -i \
		-e "s#/var/lib/games/nibbles.score#${GAMES_STATEDIR}/nibbles.scores#" \
		scoring.h \
		|| die "sed failed"
	sed -i \
		-e '/c.o:/d' \
		-e '/CC.*-c/d' \
		-e '/^CC/d' Makefile \
		|| die "sed failed"
}

src_install() {
	dogamesbin nibbles || die "dogamesbin"

	insinto "${GAMES_DATADIR#${EPREFIX}}/${PN}"
	doins nibbles.levels/* || die "doins failed"

	dodir "${GAMES_STATEDIR#${EPREFIX}}"
	touch "${D}${GAMES_STATEDIR}/nibbles.scores"

	dodoc HISTORY CREDITS TODO README

	prepgamesdirs

	fperms 664 "${GAMES_STATEDIR#${EPREFIX}}/nibbles.scores"
}
