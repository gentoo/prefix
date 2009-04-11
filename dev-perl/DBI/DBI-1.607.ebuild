# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DBI/DBI-1.607.ebuild,v 1.2 2009/02/13 10:26:54 armin76 Exp $

MODULE_AUTHOR=TIMB
inherit perl-module eutils

DESCRIPTION="The Perl DBI Module"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris"
IUSE=""
SRC_TEST="do"

DEPEND=">=dev-perl/PlRPC-0.2
	>=virtual/perl-Sys-Syslog-0.17
	dev-lang/perl"

mydoc="ToDo"
