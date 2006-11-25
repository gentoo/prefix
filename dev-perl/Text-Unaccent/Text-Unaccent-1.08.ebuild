# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Unaccent/Text-Unaccent-1.08.ebuild,v 1.14 2006/08/25 15:00:47 mcummings Exp $

EAPI="prefix"

inherit perl-module eutils

DESCRIPTION="Removes accents from a string"
HOMEPAGE="http://search.cpan.org/~ldachary/${P}/"
SRC_URI="mirror://cpan/authors/id/L/LD/LDACHARY/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

SRC_TEST="do"


DEPEND="dev-lang/perl"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/text-unaccent_size_t.diff
}
