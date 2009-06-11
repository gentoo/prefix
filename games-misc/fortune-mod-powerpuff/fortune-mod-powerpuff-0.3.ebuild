# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-misc/fortune-mod-powerpuff/fortune-mod-powerpuff-0.3.ebuild,v 1.3 2006/07/19 19:55:45 flameeyes Exp $

MY_PN=powerpuff
DESCRIPTION="Quotes taken from the Power Puff Girls series from Cartoon Network"
HOMEPAGE="http://eol.init1.nl/content/view/43/54/"
SRC_URI="http://eelco.is.a.rootboy.net/fortunecookies/${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="games-misc/fortune-mod"

S=${WORKDIR}/${MY_PN}-${PV}

src_install() {
	insinto /usr/share/fortune
	doins powerpuff powerpuff.dat || die
}
