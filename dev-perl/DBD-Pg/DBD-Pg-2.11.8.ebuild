# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DBD-Pg/DBD-Pg-2.11.8.ebuild,v 1.2 2009/01/20 09:34:40 tove Exp $

MODULE_AUTHOR=TURNSTEP
inherit perl-module eutils

DESCRIPTION="The Perl DBD::Pg Module"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="virtual/perl-Test-Simple
	virtual/perl-version
	>=virtual/perl-Test-Harness-2.03
	>=dev-perl/DBI-1.52
	>=virtual/postgresql-base-7.3"

mydoc="README"

# testcases require a local database with an
# open password for the postgres user.
SRC_TEST="skip"

src_compile() {
	postgres_include="$(readlink -f ${EPREFIX}/usr/include/postgresql)"
	postgres_lib="${postgres_include//include/lib}"
	# Fall-through case is the non-split postgresql
	# The active cases instead get us the matching libdir for the includedir.
	for i in lib lib64 ; do
		if [ -d ${postgres_lib}/${i} ]; then
			postgres_lib="${postgres_lib}/${i}"
			break
		fi
	done

	# env variables for compilation:
	export POSTGRES_INCLUDE="${postgres_include}"
	export POSTGRES_LIB="${postgres_lib}"
	perl-module_src_compile
}
