# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/IO/IO-1.23.01.ebuild,v 1.9 2007/11/19 03:52:29 kumba Exp $

EAPI="prefix"

inherit versionator perl-module

MY_P="${PN}-$(delete_version_separator 2)"
S=${WORKDIR}/${MY_P}

DESCRIPTION="load various IO modules"
HOMEPAGE="http://search.cpan.org/~gbarr"
SRC_URI="mirror://cpan/authors/id/G/GB/GBARR/${MY_P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

DEPEND="dev-lang/perl"
