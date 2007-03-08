# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-LevenshteinXS/Text-LevenshteinXS-0.03.ebuild,v 1.9 2007/01/19 16:58:30 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="An XS implementation of the Levenshtein edit distance"
HOMEPAGE="http://search.cpan.org/~jgoldberg/"
SRC_URI="mirror://cpan/authors/id/J/JG/JGOLDBERG/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

SRC_TEST="do"


DEPEND="dev-lang/perl"
