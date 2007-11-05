# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit flag-o-matic

COMMON_PV=1.20.0
CLIENTS_PV=1.20.0
M5_PV=5.2.0
SQL_PV=2.20.0

DESCRIPTION="MonetDB/SQL is a main-memory column-store database"
HOMEPAGE="http://monetdb.cwi.nl/"
SRC_URI="mirror://sourceforge/monetdb/MonetDB-${COMMON_PV}.tar.gz
	mirror://sourceforge/monetdb/clients-${CLIENTS_PV}.tar.gz
	mirror://sourceforge/monetdb/MonetDB5-${M5_PV}.tar.gz
	mirror://sourceforge/monetdb/sql-${SQL_PV}.tar.gz"

LICENSE="MPL-1.1"
SLOT="5"
KEYWORDS="~amd64 ~x86"
IUSE="python perl php java"

S=${WORKDIR}

DEPEND="dev-libs/libpcre
	dev-libs/openssl
	sys-libs/readline
	python? ( dev-lang/python )
	perl? ( dev-lang/perl )
	php? ( dev-lang/php )
	java? ( dev-java/ant >=virtual/jdk-1.4 <=virtual/jdk-1.6 )"
RDEPEND="${DEPEND}"

pkg_preinst() {
	enewgroup monetdb
	enewuser monetdb
}

src_compile() {
	local myconf=
	# Upstream likes to stick things like -O6 and what more in CFLAGS
	myconf="${myconf} --disable-strict --disable-optimize --disable-assert"
	# Deal with auto-dependencies
	myconf="${myconf} $(use_with python)"
	myconf="${myconf} $(use_with perl)"
	myconf="${myconf} $(use_with php)"
	myconf="${myconf} $(use_with java)"

	cd "${S}"/MonetDB-${COMMON_PV} || die
	econf ${myconf} || die
	emake || die "common"

	mkdir "${T}"/bin
	cp conf/monetdb-config "${T}"/bin/monetdb-config
	chmod 755 "${T}"/bin/monetdb-config

	append-flags -I"${S}"/MonetDB-${COMMON_PV}/src/common
	append-ldflags -L"${S}"/MonetDB-${COMMON_PV}/src/common/.libs
	cd "${S}"/clients-${CLIENTS_PV} || die
	econf --with-monetdb="${T}" ${myconf} || die
	emake || die "clients"

	append-flags -I"${S}"/MonetDB-${COMMON_PV}/src/gdk
	append-ldflags -L"${S}"/MonetDB-${COMMON_PV}/src/gdk/.libs
	append-flags -I"${S}"/clients-${CLIENTS_PV}/src
	append-ldflags -L"${S}"/clients-${CLIENTS_PV}/src/mapilib/.libs
	cd "${S}"/MonetDB5-${M5_PV} || die
	econf --with-monetdb="${T}" ${myconf} || die
	emake || die "MonetDB5"

	cp conf/monetdb5-config "${T}"/bin/monetdb5-config
	chmod 755 "${T}"/bin/monetdb5-config

	append-flags -I"${S}"/MonetDB5-${M5_PV}
	append-flags -I"${S}"/MonetDB5-${M5_PV}/src/{mal,optimizer,scheduler}
	append-ldflags -L"${S}"/MonetDB5-${M5_PV}/src/{mal,optimizer,scheduler}/.libs
	append-flags -I"${S}"/MonetDB5-${M5_PV}/src/modules/{atoms,kernel,mal}
	append-ldflags -L"${S}"/MonetDB5-${M5_PV}/src/modules/{atoms,kernel,mal}/.libs
	cd "${S}"/sql-${SQL_PV} || die
	econf --with-monetdb="${T}" --with-monetdb5="${T}" ${myconf} || die
	emake || die "sql"
}

src_install() {
	cd "${S}"/MonetDB-${COMMON_PV} || die
	emake DESTDIR="${D}" install || die "common"

	cd "${S}"/clients-${CLIENTS_PV} || die
	emake DESTDIR="${D}" install || die "clients"

	cd "${S}"/MonetDB5-${M5_PV} || die
	# parallel is broken here
	emake -j1 DESTDIR="${D}" install || die "MonetDB5"

	cd "${S}"/sql-${SQL_PV} || die
	emake DESTDIR="${D}" install || die "sql"

	# remove testing framework and compiled tests
	rm -f \
		"${ED}/usr/bin/Mapprove.py" \
		"${ED}/usr/bin/Mdiff" \
		"${ED}/usr/bin/Mfilter.py" \
		"${ED}/usr/bin/MkillUsers" \
		"${ED}/usr/bin/Mlog" \
		"${ED}/usr/bin/Mprofile.py" \
		"${ED}/usr/bin/Mtest.py" \
		"${ED}/usr/bin/Mtimeout" \
		"${ED}/usr/bin/prof.py" \
		"${ED}/usr/share/MonetDB/Mprofile-commands.lst" \
		"${ED}/usr/MonetDB" \
		|| die "removing testing tools"
	rm -Rf \
		"${ED}/usr/lib/MonetDB/Tests" \
		"${ED}/usr/lib/sql/Tests" \
		"${ED}/usr/share/MonetDB/Tests" \
		"${ED}/usr/share/sql/Tests" \
		|| die "removing tests"
	# remove windows cruft
	find "${ED}" -name "*.bat" | xargs rm -f || die "removing windows stuff"

	newinitd "${FILESDIR}/${PN}.init-5.2.0" monetdb || die "init.d script"
	newconfd "${FILESDIR}/${PN}.conf-5.2.0" monetdb || die "conf.d file"
}
