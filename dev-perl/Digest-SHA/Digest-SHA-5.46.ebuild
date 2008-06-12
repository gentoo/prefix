# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Digest-SHA/Digest-SHA-5.46.ebuild,v 1.1 2008/04/30 09:10:52 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=MSHELOR

inherit perl-module

DESCRIPTION="Perl extension for SHA-1/224/256/384/512"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
