# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DBI/DBI-1.608.ebuild,v 1.1 2009/05/06 08:54:42 tove Exp $

EAPI=2

MODULE_AUTHOR=TIMB
inherit perl-module eutils

DESCRIPTION="The Perl DBI Module"

SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris"
IUSE=""

DEPEND=">=dev-perl/PlRPC-0.2
	>=virtual/perl-Sys-Syslog-0.17
	virtual/perl-File-Spec"
RDEPEND="${DEPEND}"

SRC_TEST="do"
mydoc="ToDo"
