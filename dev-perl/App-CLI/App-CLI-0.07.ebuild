# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/App-CLI/App-CLI-0.07.ebuild,v 1.2 2008/11/18 14:21:07 tove Exp $

inherit perl-module

DESCRIPTION="Dispatcher module for command line interface programs"
SRC_URI="mirror://cpan/authors/id/C/CL/CLKAO/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~clkao/"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl
	>=virtual/perl-Getopt-Long-2.35
	virtual/perl-Locale-Maketext-Simple
	virtual/perl-Pod-Simple"
