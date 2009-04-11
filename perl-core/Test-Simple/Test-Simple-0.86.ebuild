# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Test-Simple/Test-Simple-0.86.ebuild,v 1.1 2008/11/21 08:16:01 tove Exp $

MODULE_AUTHOR=MSCHWERN
inherit perl-module

DESCRIPTION="Basic utilities for writing tests"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl"

SRC_TEST="do"

mydoc="rfc*.txt"
