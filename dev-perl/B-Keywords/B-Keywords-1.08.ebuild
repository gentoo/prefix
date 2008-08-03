# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/B-Keywords/B-Keywords-1.08.ebuild,v 1.1 2008/08/02 19:30:48 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=JJORE
inherit perl-module

DESCRIPTION="Lists of reserved barewords and symbol names"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND="dev-lang/perl"

SRC_TEST="do"
