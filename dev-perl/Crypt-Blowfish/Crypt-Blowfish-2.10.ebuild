# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Crypt-Blowfish/Crypt-Blowfish-2.10.ebuild,v 1.10 2007/01/15 15:29:39 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Crypt::Blowfish module for perl"
HOMEPAGE="http://search.cpan.org/~dparis/"
SRC_URI="mirror://cpan/authors/id/D/DP/DPARIS/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="virtual/libc
	>=dev-lang/perl-5"

export OPTIMIZE="${CFLAGS}"
