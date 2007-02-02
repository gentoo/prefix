# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Locale-gettext/Locale-gettext-1.05.ebuild,v 1.15 2006/10/10 19:53:59 mcummings Exp $

EAPI="prefix"

inherit perl-module

MY_P="gettext-${PV}"
S=${WORKDIR}/${MY_P}

DESCRIPTION="A Perl module for accessing the GNU locale utilities"
HOMEPAGE="http://search.cpan.org/~pvandry/${P}/"
SRC_URI="mirror://cpan/authors/id/P/PV/PVANDRY/${MY_P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="sys-devel/gettext
	>=virtual/perl-Test-Simple-0.54
	dev-lang/perl"

# Disabling the tests - not ready for prime time - mcummings
#SRC_TEST="do"

