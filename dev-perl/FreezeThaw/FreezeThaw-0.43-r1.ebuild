# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/FreezeThaw/FreezeThaw-0.43-r1.ebuild,v 1.16 2007/07/10 23:33:28 mr_bones_ Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="converting Perl structures to strings and back"
SRC_URI="mirror://cpan/authors/id/I/IL/ILYAZ/modules/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~ilyaz/"
IUSE=""
SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"

DEPEND="dev-lang/perl"
