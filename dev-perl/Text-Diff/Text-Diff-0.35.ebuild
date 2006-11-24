# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Diff/Text-Diff-0.35.ebuild,v 1.16 2006/08/06 00:22:32 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Easily create test classes in an xUnit style."
HOMEPAGE="http://search.cpan.org/~rbs/${P}/"
SRC_URI="mirror://cpan/authors/id/R/RB/RBS/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

DEPEND="dev-perl/Algorithm-Diff
	dev-lang/perl"
RDEPEND="${DEPEND}"

