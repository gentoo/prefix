# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/PodParser/PodParser-1.35.ebuild,v 1.9 2007/05/05 18:26:38 dertobi123 Exp $

EAPI="prefix"

inherit perl-module

MY_P=Pod-Parser-${PV}

DESCRIPTION="Base class for creating POD filters and translators"
HOMEPAGE="http://search.cpan.org/~marekr/"
SRC_URI="mirror://cpan/authors/id/M/MA/MAREKR/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl"

S=${WORKDIR}/${MY_P}

SRC_TEST="do"
