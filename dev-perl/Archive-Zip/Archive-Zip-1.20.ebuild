# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Archive-Zip/Archive-Zip-1.20.ebuild,v 1.9 2008/03/28 09:52:15 jer Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="A wrapper that lets you read Zip archive members as if they were files"
HOMEPAGE="http://search.cpan.org/~adamk/"
SRC_URI="mirror://cpan/authors/id/A/AD/ADAMK/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND=">=dev-perl/Compress-Zlib-1.14
	>=dev-perl/File-Which-0.05
	>=virtual/perl-File-Spec-0.80
	dev-lang/perl"

SRC_TEST="do"
