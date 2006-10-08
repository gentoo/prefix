# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Test/Test-1.25.ebuild,v 1.6 2006/08/04 13:31:50 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Utilities for writing test scripts"
HOMEPAGE="http://www.cpan.org/modules/by-authors/Test/${P}.readme"
SRC_URI="mirror://cpan/authors/id/S/SB/SBURKE/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND="dev-lang/perl
		perl-core/Test-Harness"
RDEPEND="${DEPEND}"

SRC_TEST="do"
