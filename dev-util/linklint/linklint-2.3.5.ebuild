# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/linklint/linklint-2.3.5.ebuild,v 1.5 2008/09/20 14:40:38 coldwind Exp $

DESCRIPTION="a Perl program that checks links on web sites."
HOMEPAGE="http://www.linklint.org/"
SRC_URI="http://www.linklint.org/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="dev-lang/perl"

src_install() {
	sed -i -e '1c\#!'"${EPREFIX}"'/usr/bin/perl -- # -*- perl -*-' linklint
	exeinto /usr/bin
	newexe ${P} linklint || die
	dodoc INSTALL.unix INSTALL.windows LICENSE.txt READ_ME.txt CHANGES.txt
	dohtml doc/*
}
