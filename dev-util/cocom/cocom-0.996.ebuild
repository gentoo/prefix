# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cocom/cocom-0.996.ebuild,v 1.1 2008/11/28 06:15:43 vapier Exp $

inherit autotools

DESCRIPTION="Tool set oriented onto the creation of compilers, cross-compilers, interpreters, and other language processors"
HOMEPAGE="http://cocom.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"/REGEX
	eautoconf
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc CHANGES README
}
