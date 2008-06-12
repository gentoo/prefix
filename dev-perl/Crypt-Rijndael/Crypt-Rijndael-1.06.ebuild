# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Crypt-Rijndael/Crypt-Rijndael-1.06.ebuild,v 1.1 2008/04/29 05:59:44 yuval Exp $

EAPI="prefix"

inherit perl-module eutils

DESCRIPTION="Crypt::CBC compliant Rijndael encryption module"
HOMEPAGE="http://search.cpan.org/~bdfoy/${P}/"
SRC_URI="mirror://cpan/authors/id/B/BD/BDFOY/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
