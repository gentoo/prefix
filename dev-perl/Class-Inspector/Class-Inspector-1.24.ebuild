# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Class-Inspector/Class-Inspector-1.24.ebuild,v 1.1 2009/04/21 16:33:07 tove Exp $

EAPI=2

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="Provides information about Classes"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE="test"

RDEPEND=""
DEPEND="${RDEPEND}
	test? ( virtual/perl-Test-Simple )"

SRC_TEST="do"
