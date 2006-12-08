# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/IO/IO-1.23.01.ebuild,v 1.2 2006/11/07 06:30:45 opfer Exp $

EAPI="prefix"

inherit versionator perl-module

MY_P="${PN}-$(delete_version_separator 2)"
S=${WORKDIR}/${MY_P}


DESCRIPTION="load various IO modules"
HOMEPAGE="http://search.cpan.org/~gbarr"
SRC_URI="mirror://cpan/authors/id/G/GB/GBARR/${MY_P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND="dev-lang/perl"
