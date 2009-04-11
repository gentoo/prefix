# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Clone/Clone-0.30.ebuild,v 1.1 2008/12/15 15:38:12 tove Exp $

MODULE_AUTHOR=RDF
inherit perl-module

DESCRIPTION="Recursively copy Perl datatypes"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

SRC_TEST="do"
mymake='OPTIMIZE=${CFLAGS}'
DEPEND="dev-lang/perl"
