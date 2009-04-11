# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Crypt-Twofish/Crypt-Twofish-2.12.ebuild,v 1.8 2007/01/15 15:38:29 mcummings Exp $

inherit perl-module

DESCRIPTION="The Twofish Encryption Algorithm"
HOMEPAGE="http://search.cpan.org/~ams/"
SRC_URI="mirror://cpan/authors/id/A/AM/AMS/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"
DEPEND="dev-lang/perl"
