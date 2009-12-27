# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DBD-SQLite/DBD-SQLite-1.27.ebuild,v 1.2 2009/12/24 20:25:31 tove Exp $

EAPI=2

MODULE_AUTHOR=ADAMK
inherit perl-module eutils

DESCRIPTION="Self Contained RDBMS in a DBI Driver"

SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=dev-perl/DBI-1.57
	>=dev-db/sqlite-3.6.0
	!<dev-perl/DBD-SQLite-1"
DEPEND="${RDEPEND}"

SRC_TEST="do"

src_prepare() {
	perl-module_src_prepare
	sed -i 's/^if ( 0 )/if ( 1 )/' "${S}"/Makefile.PL || die
	sed -i "/DBD::SQLite::db->install_method('sqlite_enable_load_extension');/d" "${S}"/lib/DBD/SQLite.pm || die
}
