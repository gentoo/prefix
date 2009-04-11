# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/CGI/CGI-3.42.ebuild,v 1.1 2008/09/09 08:33:19 tove Exp $

MODULE_AUTHOR=LDS
inherit perl-module

MY_P=${PN}.pm-${PV}
DESCRIPTION="Simple Common Gateway Interface Class"
SRC_URI="mirror://cpan/authors/id/L/LD/LDS/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl"
#	dev-perl/FCGI" #236921

S=${WORKDIR}/${MY_P}

SRC_TEST="do"
myconf="INSTALLDIRS=vendor"
