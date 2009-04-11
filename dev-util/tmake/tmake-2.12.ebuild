# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/tmake/tmake-2.12.ebuild,v 1.6 2009/01/08 02:54:54 darkside Exp $

DESCRIPTION="A Cross platform Makefile tool"
SRC_URI="mirror://sourceforge/tmake/${P}.tar.bz2"
HOMEPAGE="http://tmake.sourceforge.net"

RDEPEND=">=dev-lang/perl-5"

SLOT="0"
LICENSE="as-is"
KEYWORDS="~x86-linux ~ppc-macos"
IUSE=""

src_install () {
	sed -i -e '1c\#!'"${EPREFIX}"'/usr/bin/perl' "${S}"/bin/tmake "${S}"/bin/progen
	dobin bin/tmake bin/progen
	dodir /usr/lib/tmake
	cp -pPRf "${S}"/lib/* "${ED}"/usr/lib/tmake
	dodoc README
	dohtml -r doc/*
	dodir /etc/env.d
	echo "TMAKEPATH=${EPREFIX}/usr/lib/tmake/linux-g++" > ${ED}/etc/env.d/51tmake
}
