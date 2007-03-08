# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-CSV-Simple/Text-CSV-Simple-1.00.ebuild,v 1.5 2007/01/19 16:57:26 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Text::CSV::Simple - Simpler parsing of CSV files"
SRC_URI="mirror://cpan/authors/id/T/TM/TMTM/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~tmtm/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""
SRC_TEST="do"
DEPEND="dev-perl/Text-CSV_XS
		dev-perl/Class-Trigger
		dev-perl/File-Slurp
		dev-lang/perl"
