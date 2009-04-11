# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Crypt-Rijndael/Crypt-Rijndael-1.06.ebuild,v 1.2 2008/06/13 17:01:43 armin76 Exp $

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
