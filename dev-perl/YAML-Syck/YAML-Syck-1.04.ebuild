# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/YAML-Syck/YAML-Syck-1.04.ebuild,v 1.1 2008/04/28 23:31:44 yuval Exp $

inherit perl-module

DESCRIPTION="Fast, lightweight YAML loader and dumper"
HOMEPAGE="http://search.cpan.org/~audreyt/"
SRC_URI="mirror://cpan/authors/id/A/AU/AUDREYT/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="|| ( dev-libs/syck >=dev-lang/ruby-1.8 )
		dev-lang/perl"
