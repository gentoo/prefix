# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Geography-Countries/Geography-Countries-1.4.ebuild,v 1.17 2008/05/17 11:30:12 nixnut Exp $

inherit perl-module

DESCRIPTION="2-letter, 3-letter, and numerical codes for countries."
SRC_URI="mirror://cpan/authors/id/A/AB/ABIGAIL/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~abigail/"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
