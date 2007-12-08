# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Crypt-CAST5_PP/Crypt-CAST5_PP-1.04.ebuild,v 1.6 2007/03/05 11:30:00 ticho Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="CAST5 block cipher in pure Perl"
HOMEPAGE="http://search.cpan.org/~bobmath/${P}/"
SRC_URI="mirror://cpan/authors/id/B/BO/BOBMATH/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE=""

SRC_TEST="do"
DEPEND="dev-lang/perl"
