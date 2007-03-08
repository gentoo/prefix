# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Shellwords/Text-Shellwords-1.08.ebuild,v 1.9 2007/03/05 12:33:41 ticho Exp $

EAPI="prefix"

IUSE=""

inherit perl-module

MY_P=Text-Shellwords-${PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Provides shellwords() routine which parses lines of text and returns a set of tokens using the same rules that the Unix shell does."

SRC_URI="mirror://cpan/authors/id/L/LD/LDS/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~lds/"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"

SRC_TEST="do"


DEPEND="dev-lang/perl"
