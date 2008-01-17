# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-dicts/migemo-dict/migemo-dict-200309.ebuild,v 1.15 2005/01/01 12:56:46 eradicator Exp $

EAPI="prefix"

IUSE=""

DESCRIPTION="Dictionary files for the Migemo and C/Migemo"
HOMEPAGE="http://openlab.ring.gr.jp/skk/dic.html"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
SLOT="0"

DEPEND=""

src_install() {
	insinto /usr/share/migemo
	doins migemo-dict
}
