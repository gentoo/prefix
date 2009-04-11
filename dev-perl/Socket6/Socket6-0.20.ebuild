# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Socket6/Socket6-0.20.ebuild,v 1.3 2008/11/04 10:20:26 vapier Exp $

MODULE_AUTHOR=UMEMOTO
inherit perl-module

DESCRIPTION="IPv6 related part of the C socket.h defines and structure manipulators"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
