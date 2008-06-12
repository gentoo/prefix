# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/File-Copy-Recursive/File-Copy-Recursive-0.33.ebuild,v 1.6 2008/03/19 03:18:21 jer Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="uses File::Copy to recursively copy dirs"
HOMEPAGE="http://search.cpan.org/~dmuey/"
SRC_URI="mirror://cpan/authors/id/D/DM/DMUEY/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND="dev-lang/perl"
