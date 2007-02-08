# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/dev-lang/lua-wrapper/lua-wrapper-1.ebuild,v 1.4 2007/01/10 21:14:08 mabi Exp $

EAPI="prefix"

DESCRIPTION="A small shell script to choose the enable different lua versions"
HOMEPAGE="http://dev.gentoo.org/~mabi/lua-wrapper/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

src_install () {
	exeinto /usr/bin
	newexe ${FILESDIR}/${P}.sh lua-config || die "Install failed"
}
