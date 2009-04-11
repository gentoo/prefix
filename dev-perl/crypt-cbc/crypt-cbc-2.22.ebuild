# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/crypt-cbc/crypt-cbc-2.22.ebuild,v 1.8 2008/03/19 03:24:38 jer Exp $

inherit perl-module

MY_P=Crypt-CBC-${PV}
S=${WORKDIR}/${MY_P}
DESCRIPTION="Encrypt Data with Cipher Block Chaining Mode"
HOMEPAGE="http://search.cpan.org/CPAN/authors/id/L/LD/LDS/Crypt-Cbc-2.17.readme"
SRC_URI="mirror://cpan/authors/id/L/LD/LDS/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND="virtual/perl-Digest-MD5
	dev-lang/perl"
