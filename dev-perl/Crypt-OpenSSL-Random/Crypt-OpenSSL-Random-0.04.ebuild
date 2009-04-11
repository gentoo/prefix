# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Crypt-OpenSSL-Random/Crypt-OpenSSL-Random-0.04.ebuild,v 1.9 2008/03/28 08:35:40 jer Exp $

inherit perl-module

DESCRIPTION="Crypt::OpenSSL::Random module for perl"
HOMEPAGE="http://search.cpan.org/~iroberts/"
SRC_URI="mirror://cpan/authors/id/I/IR/IROBERTS/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-libs/openssl
	dev-lang/perl"

export OPTIMIZE="${CFLAGS}"
mydoc="ToDo"
