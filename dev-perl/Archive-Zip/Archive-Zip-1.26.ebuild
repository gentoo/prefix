# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Archive-Zip/Archive-Zip-1.26.ebuild,v 1.1 2008/10/20 18:02:18 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="A wrapper that lets you read Zip archive members as if they were files"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=">=dev-perl/Compress-Zlib-1.14
	>=virtual/perl-File-Spec-0.80
	dev-lang/perl"

SRC_TEST="do"
