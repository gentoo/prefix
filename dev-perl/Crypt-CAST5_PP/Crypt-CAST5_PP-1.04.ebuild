# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Crypt-CAST5_PP/Crypt-CAST5_PP-1.04.ebuild,v 1.7 2008/03/19 03:34:01 jer Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="CAST5 block cipher in pure Perl"
HOMEPAGE="http://search.cpan.org/~bobmath/${P}/"
SRC_URI="mirror://cpan/authors/id/B/BO/BOBMATH/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"
DEPEND="dev-lang/perl"
