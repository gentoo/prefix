# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IP-Country/IP-Country-2.27.ebuild,v 1.1 2009/08/25 17:31:24 robbat2 Exp $

MODULE_AUTHOR="NWETTERS"
inherit perl-module

DESCRIPTION="fast lookup of country codes from IP addresses"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-perl/Geography-Countries
	dev-lang/perl"
mydoc="TODO"
