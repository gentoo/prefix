# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Archive-Zip/Archive-Zip-1.20.ebuild,v 1.1 2007/06/09 10:12:58 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="A wrapper that lets you read Zip archive members as if they were files"
HOMEPAGE="http://search.cpan.org/~adamk/"
SRC_URI="mirror://cpan/authors/id/A/AD/ADAMK/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND=">=dev-perl/Compress-Zlib-1.14
	>=dev-perl/File-Which-0.05
	>=virtual/perl-File-Spec-0.80
	dev-lang/perl"

SRC_TEST="do"
