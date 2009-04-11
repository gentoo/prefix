# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-arcade/nibbles/nibbles-0.0.4.ebuild,v 1.12 2009/02/02 11:41:34 tupone Exp $

EAPI=2
inherit eutils games

MY_P=${PN}-v${PV}
DESCRIPTION="An ncurses-based Nibbles clone"
HOMEPAGE="http://www.earth.li/projectpurple/progs/nibbles.html"
SRC_URI="http://www.earth.li/projectpurple/files/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="sys-libs/ncurses"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	sed -i \
		-e "s#/usr/local/games/nibbles.levels#${GAMES_DATADIR}/${PN}#" \
		nibbles.h \
		|| die "sed failed"

	sed -i \
		-e "s#/var/lib/games/nibbles.score#${GAMES_STATEDIR}/nibbles.scores#" \
		scoring.h \
		|| die "sed failed"
	epatch "${FILESDIR}"/${P}-as-needed.patch
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
