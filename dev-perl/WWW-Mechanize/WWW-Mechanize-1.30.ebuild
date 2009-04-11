# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/WWW-Mechanize/WWW-Mechanize-1.30.ebuild,v 1.7 2007/11/10 18:07:47 armin76 Exp $

inherit perl-module

DESCRIPTION="Handy web browsing in a Perl object"
SRC_URI="mirror://cpan/authors/id/P/PE/PETDANCE/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~petdance/"
IUSE="test"
SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

# Bug in the tests - improper use of HTTP::Server
SRC_TEST="do"

# configure to run the local tests, but not the ones which access the Internet
myconf="--local --mech-dump --nolive"

DEPEND="dev-lang/perl
	dev-perl/IO-Socket-SSL
	>=dev-perl/libwww-perl-5.76
	>=dev-perl/URI-1.25
	>=dev-perl/HTML-Parser-3.34
	dev-perl/Test-LongString
	test? ( dev-perl/Test-Pod
	dev-perl/Test-Taint
	dev-perl/Test-Warn
	dev-perl/Test-Memory-Cycle )"
