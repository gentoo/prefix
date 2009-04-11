# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Memoize/Memoize-1.01.ebuild,v 1.3 2006/08/04 13:28:44 mcummings Exp $

inherit perl-module

MY_P=Memoize-${PV}
DESCRIPTION="Generic Perl function result caching system"
HOMEPAGE="http://perl.plover.com/Memoize/"
SRC_URI="mirror://cpan/authors/id/M/MJ/MJD/${P}.tar.gz"

LICENSE="Artistic GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

S=${WORKDIR}/${MY_P}

DEPEND="dev-lang/perl"
