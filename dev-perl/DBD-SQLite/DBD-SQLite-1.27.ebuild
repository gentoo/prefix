# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DBD-SQLite/DBD-SQLite-1.27.ebuild,v 1.1 2009/11/24 07:40:52 robbat2 Exp $

EAPI=2

MODULE_AUTHOR=ADAMK
inherit perl-module eutils

DESCRIPTION="Self Contained RDBMS in a DBI Driver"

SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=">=dev-perl/DBI-1.57
	!<dev-perl/DBD-SQLite-1"

SRC_TEST="do"
