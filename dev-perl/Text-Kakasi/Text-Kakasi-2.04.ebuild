# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Kakasi/Text-Kakasi-2.04.ebuild,v 1.19 2007/01/19 16:58:12 mcummings Exp $

EAPI="prefix"

inherit perl-module eutils

DESCRIPTION="This module provides libkakasi interface for Perl."
HOMEPAGE="http://search.cpan.org/dist/Text-Kakasi/"
SRC_URI="mirror://cpan/authors/id/D/DA/DANKOGAI/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

DEPEND=">=app-i18n/kakasi-2.3.4
	dev-lang/perl"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/Text-Kakasi-1.05-gentoo.diff
}
