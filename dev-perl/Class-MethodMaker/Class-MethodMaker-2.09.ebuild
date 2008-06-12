# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Class-MethodMaker/Class-MethodMaker-2.09.ebuild,v 1.4 2007/07/10 23:33:29 mr_bones_ Exp $

EAPI="prefix"

inherit perl-module eutils

DESCRIPTION="Perl module for Class::MethodMaker"
HOMEPAGE="http://search.cpan.org/~schwigon"
SRC_URI="mirror://cpan/authors/id/S/SC/SCHWIGON/class-methodmaker/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE=""

#disabled until distributed with a working sig file
#SRC_TEST="do"
PREFER_BUILDPL="no"

RDEPEND="dev-lang/perl"
DEPEND="${RDEPEND}
	>=dev-perl/module-build-0.28"
