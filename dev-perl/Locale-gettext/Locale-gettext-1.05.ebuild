# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Locale-gettext/Locale-gettext-1.05.ebuild,v 1.17 2007/07/10 23:33:30 mr_bones_ Exp $

inherit perl-module

MY_P="gettext-${PV}"
S=${WORKDIR}/${MY_P}

DESCRIPTION="A Perl module for accessing the GNU locale utilities"
HOMEPAGE="http://search.cpan.org/~pvandry/"
SRC_URI="mirror://cpan/authors/id/P/PV/PVANDRY/${MY_P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="sys-devel/gettext
	dev-lang/perl"

# Disabling the tests - not ready for prime time - mcummings
#SRC_TEST="do"
