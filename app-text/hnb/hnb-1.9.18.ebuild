# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/hnb/hnb-1.9.18.ebuild,v 1.4 2006/10/22 01:37:10 tcort Exp $

EAPI="prefix"

DESCRIPTION="hnb is a program to organize many kinds of data in one place, including addresses, TODO lists, ideas, book reviews, brainstorming, speech outlines, etc. It stores data in XML format, and is capable of native export to ASCII and HTML."
SRC_URI="http://hnb.sourceforge.net/.files/${P}.tar.gz"
HOMEPAGE="http://hnb.sourceforge.net/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""

src_compile() {
	make || die
}

src_install() {
	dodoc README doc/hnbrc
	doman doc/hnb.1
	dobin src/hnb
}
