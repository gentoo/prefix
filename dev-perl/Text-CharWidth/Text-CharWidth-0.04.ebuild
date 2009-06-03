# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-CharWidth/Text-CharWidth-0.04.ebuild,v 1.17 2009/05/31 23:46:58 ranger Exp $

inherit perl-module

DESCRIPTION="Get number of occupied columns of a string on terminal"
HOMEPAGE="http://search.cpan.org/~kubota/"
SRC_URI="mirror://cpan/authors/id/K/KU/KUBOTA/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl"

SRC_TEST="do"
