# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DBD-mysql/DBD-mysql-4.01.1.ebuild,v 1.1 2009/06/10 01:47:15 robbat2 Exp $

inherit versionator

MODULE_AUTHOR="CAPTTOFU"
MY_PV="$(delete_version_separator 2)"
MY_P="${PN}-${MY_PV}"
inherit eutils perl-module

S=${WORKDIR}/${MY_P}

DESCRIPTION="The Perl DBD:mysql Module"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos"
IUSE=""

DEPEND="dev-lang/perl
	dev-perl/DBI
	virtual/mysql"

mydoc="ToDo"
