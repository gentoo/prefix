# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Term-ReadLine-Perl/Term-ReadLine-Perl-1.0203.ebuild,v 1.23 2007/07/10 23:33:27 mr_bones_ Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Quick implimentation of readline utilities."
HOMEPAGE="http:/search.cpan.org/~ilyaz/${P}/"
SRC_URI="mirror://cpan/authors/id/I/IL/ILYAZ/modules/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-lang/perl"
