# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/PlRPC/PlRPC-0.2020-r1.ebuild,v 1.7 2007/11/10 14:20:07 drac Exp $

EAPI="prefix"

inherit perl-module

S=${WORKDIR}/${PN}

DESCRIPTION="The Perl RPC Module"
SRC_URI="mirror://cpan/authors/id/M/MN/MNOONING/${PN}/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~mnooning/"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86 ~x86-fbsd ~x86-macos"
IUSE=""

PATCHES="${FILESDIR}/perldoc-remove.patch"

DEPEND=">=virtual/perl-Storable-1.0.7
	>=dev-perl/Net-Daemon-0.34
	dev-lang/perl"
