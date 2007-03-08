# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/digest-base/digest-base-1.15.ebuild,v 1.11 2007/03/03 20:40:24 ticho Exp $

EAPI="prefix"

inherit perl-module

MY_P=Digest-${PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Modules that calculate message digests"
HOMEPAGE="http://search.cpan.org/~gaas/"
SRC_URI="mirror://cpan/authors/id/G/GA/GAAS/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

DEPEND="dev-lang/perl
		virtual/perl-MIME-Base64"

SRC_TEST="do"
mydoc="rfc*.txt"
