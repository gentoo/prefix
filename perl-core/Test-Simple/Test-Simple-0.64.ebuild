# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Test-Simple/Test-Simple-0.64.ebuild,v 1.3 2006/10/15 20:55:30 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Basic utilities for writing tests"
SRC_URI="mirror://cpan/authors/id/M/MS/MSCHWERN/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~mschwern/${P}/"
IUSE=""
SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64 ~ppc-macos ~x86"

mydoc="rfc*.txt"
myconf="INSTALLDIRS=vendor"
DEPEND=">=dev-lang/perl-5.8.0-r12
		>=perl-core/Test-Harness-2.03"

SRC_TEST="do"
