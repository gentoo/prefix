# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr-util/apr-util-1.2.8-r1.ebuild,v 1.3 2007/07/31 10:35:02 phreak Exp $

EAPI="prefix"

inherit autotools eutils flag-o-matic libtool db-use

DBD_MYSQL=84

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.gz
	mirror://apache/apr/apr-${PV}.tar.gz
	mysql? ( mirror://gentoo/apr_dbd_mysql-r${DBD_MYSQL}.c )"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~ppc-aix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="berkdb gdbm ldap mysql postgres sqlite sqlite3"
RESTRICT="test"

DEPEND="dev-libs/expat
	>=dev-libs/apr-${PV}
	berkdb? ( =sys-libs/db-4* )
	gdbm? ( sys-libs/gdbm )
	ldap? ( =net-nds/openldap-2* )
	mysql? ( =virtual/mysql-5* )
	postgres? ( dev-db/libpq )
	sqlite? ( =dev-db/sqlite-2* )
	sqlite3? ( =dev-db/sqlite-3* )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	if use mysql ; then
		cp "${DISTDIR}"/apr_dbd_mysql-r${DBD_MYSQL}.c \
			"${S}"/dbd/apr_dbd_mysql.c || die "could not copy mysql driver"
	fi

	./buildconf --with-apr=../apr-${PV} || die "buildconf failed"
	elibtoolize || die "elibtoolize failed"
}

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
		${myconf} || die "econf failed!"

	emake || die "emake failed!"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	dodoc CHANGES NOTICE

	# This file is only used on AIX systems, which gentoo is not,
	# and causes collisions between the SLOTs, so kill it
	rm "${ED}"/usr/$(get_libdir)/aprutil.exp
}
