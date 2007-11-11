# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Net-Daemon/Net-Daemon-0.43.ebuild,v 1.9 2007/11/10 14:10:23 drac Exp $

EAPI="prefix"

inherit perl-module

S=${WORKDIR}/${PN}

DESCRIPTION="Abstract base class for portable servers"
HOMEPAGE="http://search.cpan.org/~mnooning/"
SRC_URI="mirror://cpan/authors/id/M/MN/MNOONING/${PN}/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86 ~x86-fbsd ~x86-macos"
IUSE=""

DEPEND="dev-lang/perl"
