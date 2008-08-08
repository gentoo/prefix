# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/File-Next/File-Next-1.02.ebuild,v 1.1 2008/05/15 23:29:26 drac Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="File::Next is an iterator-based module for finding files"
HOMEPAGE="http://search.cpan.org/search?query=File-Next"
SRC_URI="mirror://cpan/authors/id/P/PE/PETDANCE/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="virtual/perl-File-Spec
	virtual/perl-Test-Simple"
