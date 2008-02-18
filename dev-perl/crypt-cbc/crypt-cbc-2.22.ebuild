# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/crypt-cbc/crypt-cbc-2.22.ebuild,v 1.7 2007/05/05 18:14:07 dertobi123 Exp $

EAPI="prefix"

inherit perl-module

MY_P=Crypt-CBC-${PV}
S=${WORKDIR}/${MY_P}
DESCRIPTION="Encrypt Data with Cipher Block Chaining Mode"
HOMEPAGE="http://search.cpan.org/CPAN/authors/id/L/LD/LDS/Crypt-Cbc-2.17.readme"
SRC_URI="mirror://cpan/authors/id/L/LD/LDS/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND="virtual/perl-Digest-MD5
	dev-lang/perl"
