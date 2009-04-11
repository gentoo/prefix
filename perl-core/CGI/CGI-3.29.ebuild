# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/CGI/CGI-3.29.ebuild,v 1.9 2008/03/28 06:17:37 jer Exp $

inherit perl-module

myconf="INSTALLDIRS=vendor"
MY_P=${PN}.pm-${PV}
DESCRIPTION="Simple Common Gateway Interface Class"
HOMEPAGE="http://search.cpan.org/~lds/"
SRC_URI="mirror://cpan/authors/id/L/LD/LDS/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl"

S=${WORKDIR}/${MY_P}

SRC_TEST="do"
