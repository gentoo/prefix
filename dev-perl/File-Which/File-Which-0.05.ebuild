# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/File-Which/File-Which-0.05.ebuild,v 1.12 2008/03/28 09:51:18 jer Exp $

inherit perl-module

DESCRIPTION="Perl module implementing \`which' internally"
HOMEPAGE="http://search.cpan.org/search?module=File::Which"
SRC_URI="mirror://cpan/authors/id/P/PE/PEREINAR/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl"

SRC_TEST="do"
mydoc="TODO"
