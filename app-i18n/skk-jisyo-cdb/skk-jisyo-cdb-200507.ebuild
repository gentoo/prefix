# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/skk-jisyo-cdb/skk-jisyo-cdb-200507.ebuild,v 1.1 2005/07/02 09:40:24 usata Exp $

EAPI="prefix"

DESCRIPTION="Dictionary files for the SKK Japanese-input software in CDB format"
HOMEPAGE="http://openlab.ring.gr.jp/skk/dic.html"
SRC_URI="mirror://gentoo/${P}.tar.gz
	http://dev.gentoo.org/~usata/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""

src_install() {
	# install dictionaries
	insinto /usr/share/skk
	doins SKK-JISYO.{L,M,S}.cdb || die
}
