# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/PodParser/PodParser-1.35.ebuild,v 1.1 2006/11/06 17:07:57 mcummings Exp $

EAPI="prefix"

inherit perl-module
MY_P=Pod-Parser-${PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Base class for creating POD filters and translators"
HOMEPAGE="http://www.cpan.org/modules/by-authors/id/M/MA/MAREKR/${MY_P}.readme"
SRC_URI="mirror://cpan/authors/id/M/MA/MAREKR/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
