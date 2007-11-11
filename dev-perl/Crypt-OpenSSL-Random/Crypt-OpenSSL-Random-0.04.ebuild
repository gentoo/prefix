# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Crypt-OpenSSL-Random/Crypt-OpenSSL-Random-0.04.ebuild,v 1.8 2007/11/10 12:26:42 drac Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Crypt::OpenSSL::Random module for perl"
HOMEPAGE="http://search.cpan.org/~iroberts/"
SRC_URI="mirror://cpan/authors/id/I/IR/IROBERTS/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86 ~x86-macos"
IUSE=""

DEPEND="dev-libs/openssl
	dev-lang/perl"

export OPTIMIZE="${CFLAGS}"
mydoc="ToDo"
