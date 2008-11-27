# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DBI/DBI-1.607.ebuild,v 1.1 2008/11/26 09:07:11 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=TIMB
inherit perl-module eutils

DESCRIPTION="The Perl DBI Module"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~x64-solaris"
IUSE=""
SRC_TEST="do"

DEPEND=">=dev-perl/PlRPC-0.2
	>=virtual/perl-Sys-Syslog-0.17
	dev-lang/perl"

mydoc="ToDo"
