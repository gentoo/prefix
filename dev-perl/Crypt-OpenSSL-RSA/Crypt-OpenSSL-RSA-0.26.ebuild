# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Crypt-OpenSSL-RSA/Crypt-OpenSSL-RSA-0.26.ebuild,v 1.1 2009/11/24 07:40:15 robbat2 Exp $

inherit perl-module

DESCRIPTION="Crypt::OpenSSL::RSA module for perl"
HOMEPAGE="http://search.cpan.org/~iroberts/${P}/"
SRC_URI="mirror://cpan/authors/id/I/IR/IROBERTS/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-perl/Crypt-OpenSSL-Bignum
	dev-perl/Crypt-OpenSSL-Random
	dev-libs/openssl
	dev-lang/perl"

SRC_TEST="do"

mydoc="rfc*.txt"
