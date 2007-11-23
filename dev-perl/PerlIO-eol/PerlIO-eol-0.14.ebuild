# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/PerlIO-eol/PerlIO-eol-0.14.ebuild,v 1.6 2007/07/13 17:06:16 armin76 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="PerlIO::eol - PerlIO layer for normalizing line endings"
SRC_URI="mirror://cpan/authors/id/A/AU/AUDREYT/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~autrijus/"

SLOT="0"
LICENSE="Artistic"
SRC_TEST="do"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

DEPEND="dev-lang/perl"
