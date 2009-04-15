# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-dicts/migemo-dict/migemo-dict-200812.ebuild,v 1.4 2009/04/14 10:32:54 armin76 Exp $

IUSE="unicode"

DESCRIPTION="Dictionary files for the Migemo and C/Migemo"
HOMEPAGE="http://openlab.ring.gr.jp/skk/dic.html"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
SLOT="0"

src_unpack() {
	unpack ${A}
	cd "${S}"
	if use unicode ; then
		iconv -f euc-jp -t utf-8 migemo-dict > "${T}/migemo-dict"
	else
		cp migemo-dict "${T}/migemo-dict"
	fi
}

src_install() {
	insinto /usr/share/migemo
	doins "${T}/migemo-dict"
}
