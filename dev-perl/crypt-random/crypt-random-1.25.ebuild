# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/crypt-random/crypt-random-1.25.ebuild,v 1.12 2006/10/20 14:51:29 mcummings Exp $

EAPI="prefix"

inherit perl-module

MY_P=Crypt-Random-${PV}
S=${WORKDIR}/${MY_P}
DESCRIPTION="Cryptographically Secure, True Random Number Generator"
HOMEPAGE="http://search.cpan.org/CPAN/authors/id/V/VI/VIPUL/${MY_P}.readme"
SRC_URI="mirror://cpan/authors/id/V/VI/VIPUL/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND=">=dev-perl/math-pari-2.010603
	dev-perl/class-loader
	dev-lang/perl"
