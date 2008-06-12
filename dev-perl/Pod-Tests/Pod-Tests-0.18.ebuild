# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Pod-Tests/Pod-Tests-0.18.ebuild,v 1.14 2007/01/19 15:30:04 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Extracts embedded tests and code examples from POD"
HOMEPAGE="http://search.cpan.org/search?module=Pod-Tests"
SRC_URI="mirror://cpan/authors/id/A/AD/ADAMK/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND=">=virtual/perl-Test-Harness-1.22
	dev-lang/perl"
