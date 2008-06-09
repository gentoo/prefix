# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/PlRPC/PlRPC-0.2020-r1.ebuild,v 1.9 2008/06/07 09:48:58 aballier Exp $

EAPI="prefix"

inherit perl-module

S=${WORKDIR}/${PN}

DESCRIPTION="The Perl RPC Module"
SRC_URI="mirror://cpan/authors/id/M/MN/MNOONING/${PN}/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~mnooning/"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

PATCHES="${FILESDIR}/perldoc-remove.patch"

DEPEND=">=virtual/perl-Storable-1.0.7
	>=dev-perl/Net-Daemon-0.34
	dev-lang/perl"
