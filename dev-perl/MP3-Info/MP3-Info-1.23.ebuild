# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/MP3-Info/MP3-Info-1.23.ebuild,v 1.6 2008/03/28 09:02:17 jer Exp $

inherit perl-module

DESCRIPTION="A Perl module to manipulate/fetch info from MP3 files"
SRC_URI="mirror://cpan/authors/id/D/DA/DANIEL/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~daniel/"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
