# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Aspell/Text-Aspell-0.06.ebuild,v 1.3 2006/09/20 21:38:14 ian Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Perl interface to the GNU Aspell Library"
SRC_URI="mirror://cpan/authors/id/H/HA/HANK/${P}.tar.gz"
HOMEPAGE="http://www.cpan.org/modules/by-authors/id/H/HA/HANK/${P}.readme"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

# Disabling tests for now - see bug #147897 --ian
#SRC_TEST="do"

DEPEND="app-text/aspell
	dev-lang/perl"
RDEPEND="${DEPEND}"
