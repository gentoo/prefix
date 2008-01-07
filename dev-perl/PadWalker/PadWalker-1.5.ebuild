# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/PadWalker/PadWalker-1.5.ebuild,v 1.3 2007/04/14 13:59:26 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="play with other peoples' lexical variables"
HOMEPAGE="http://search.cpan.org/~robin/${P}/"
SRC_URI="mirror://cpan/authors/id/R/RO/ROBIN/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
