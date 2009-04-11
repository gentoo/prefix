# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/kochi-substitute/kochi-substitute-20030809-r3.ebuild,v 1.15 2008/01/15 18:01:07 grobian Exp $

inherit font

DESCRIPTION="Kochi Japanese TrueType fonts with Wadalab Fonts"
HOMEPAGE="http://efont.sourceforge.jp/"
SRC_URI="mirror://sourceforge.jp/efont/5411/${P}.tar.bz2"

LICENSE="free-noncomm"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

S=${WORKDIR}/${PN}-${PV:0:8}

FONT_SUFFIX="ttf"

DOCS="README.ja ChangeLog docs/README"

# Only installs fonts
RESTRICT="strip binchecks"

src_install() {
	font_src_install

	cd docs
	local d
	for d in kappa20 k14goth ayu20gothic wadalab shinonome* naga10; do
		docinto $d
		dodoc $d/*
	done
}
