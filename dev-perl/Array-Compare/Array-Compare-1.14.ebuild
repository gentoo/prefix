# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Array-Compare/Array-Compare-1.14.ebuild,v 1.7 2007/08/09 14:20:46 dertobi123 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Perl extension for comparing arrays."
HOMEPAGE="http://search.cpan.org/~davecross"
SRC_URI="mirror://cpan/authors/id/D/DA/DAVECROSS/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

RDEPEND="dev-lang/perl"
DEPEND=">=dev-perl/module-build-0.28
	${RDEPEND}"
