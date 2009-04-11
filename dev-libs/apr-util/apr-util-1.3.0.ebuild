# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr-util/apr-util-1.3.0.ebuild,v 1.2 2008/06/15 16:21:55 hollow Exp $

inherit eutils flag-o-matic libtool db-use

DESCRIPTION="Apache Portable Runtime Utility Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.gz
	mirror://apache/apr/apr-${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="berkdb doc gdbm ldap mysql postgres sqlite sqlite3"
RESTRICT="test"

RDEPEND="dev-libs/expat
	>=dev-libs/apr-${PV}
	berkdb? ( =sys-libs/db-4* )
	gdbm? ( sys-libs/gdbm )
	ldap? ( =net-nds/openldap-2* )
	mysql? ( =virtual/mysql-5* )
	postgres? ( virtual/postgresql-base )
	sqlite? ( =dev-db/sqlite-2* )
	sqlite3? ( =dev-db/sqlite-3* )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

src_compile() {
	local myconf=""

	use ldap && myconf="${myconf} --with-ldap"

	if use berkdb; then
		dbver="$(db_findver sys-libs/db)" || die "Unable to find db version"
		dbver="$(db_ver_to_slot "$dbver")"
		dbver="${dbver/\./}"
		myconf="${myconf} --with-dbm=db${dbver}
		--with-berkeley-db=$(db_includedir):${EPREFIX}/usr/$(get_libdir)"
	else
		myconf="${myconf} --without-berkeley-db"
	fi

	econf --datadir="${EPREFIX}"/usr/share/apr-util-1 \
		--with-apr="${EPREFIX}"/usr \
		--with-expat="${EPREFIX}"/usr \
		$(use_with gdbm) \
		$(use_with mysql) \
		$(use_with postgres pgsql) \
		$(use_with sqlite sqlite2) \
		$(use_with sqlite3) \
		${myconf}

	emake || die "emake failed!"

	if use doc; then
		emake dox || die "emake dox failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc CHANGES NOTICE

	if use doc; then
		dohtml docs/dox/html/* || die "dohtml failed"
	fi

	# This file is only used on AIX systems, which gentoo is not,
	# and causes collisions between the SLOTs, so kill it
	rm "${ED}"/usr/$(get_libdir)/aprutil.exp
}
