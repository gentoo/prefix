# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Test-Harness/Test-Harness-2.62.ebuild,v 1.8 2006/12/24 00:57:22 dertobi123 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Runs perl standard test scripts with statistics"
HOMEPAGE="http://search.cpan.org/search?dist=Test-Harness"
SRC_URI="mirror://cpan/authors/id/P/PE/PETDANCE/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND="dev-lang/perl"
mydoc="rfc*.txt"
