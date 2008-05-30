# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Term-ANSIColor/Term-ANSIColor-1.12.ebuild,v 1.6 2008/03/28 09:04:39 jer Exp $

EAPI="prefix"

inherit perl-module

MY_PN="ANSIColor"
MY_P="$MY_PN-$PV"
S="${WORKDIR}/$MY_P"
DESCRIPTION="Color screen output using ANSI escape sequences."
SRC_URI="mirror://cpan/authors/id/R/RR/RRA/${MY_P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~rra/"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris"
IUSE="test"
SRC_TEST="do"

DEPEND="test? ( dev-perl/Test-Pod )
	dev-lang/perl"
