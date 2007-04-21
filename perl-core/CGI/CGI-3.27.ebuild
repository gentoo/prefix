# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/CGI/CGI-3.27.ebuild,v 1.4 2007/04/17 18:26:21 gustavoz Exp $

EAPI="prefix"

inherit perl-module

myconf="INSTALLDIRS=vendor"
MY_P=${PN}.pm-${PV}
DESCRIPTION="Simple Common Gateway Interface Class"
HOMEPAGE="http://search.cpan.org/author/L/LD/LDS/CGI.pm-${PV}/"
SRC_URI="mirror://cpan/authors/id/L/LD/LDS/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/perl-5.8.0-r12"

S=${WORKDIR}/${MY_P}

SRC_TEST="do"
