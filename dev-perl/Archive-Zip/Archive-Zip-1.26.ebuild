# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Archive-Zip/Archive-Zip-1.26.ebuild,v 1.2 2008/11/18 14:22:37 tove Exp $

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="A wrapper that lets you read Zip archive members as if they were files"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=">=virtual/perl-Compress-Zlib-1.14
	>=virtual/perl-File-Spec-0.80
	dev-lang/perl"

SRC_TEST="do"
