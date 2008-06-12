# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/flawfinder/flawfinder-1.27.ebuild,v 1.1 2007/06/27 12:09:37 hanno Exp $

EAPI="prefix"

DESCRIPTION="Examines C/C++ source code for security flaws"
HOMEPAGE="http://www.dwheeler.com/flawfinder/"
SRC_URI="http://www.dwheeler.com/flawfinder/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="dev-lang/python"

src_install() {
	dobin ${PN}
	doman ${PN}.1
	dodoc ChangeLog INSTALL.txt README announcement
	dodoc flawfinder.pdf
}
