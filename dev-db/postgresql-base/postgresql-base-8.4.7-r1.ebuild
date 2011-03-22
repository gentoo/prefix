# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/postgresql-base/postgresql-base-8.4.7-r1.ebuild,v 1.2 2011/03/21 23:01:01 titanofold Exp $

EAPI="3"

WANT_AUTOMAKE="none"

inherit autotools eutils multilib prefix versionator

SLOT="$(get_version_component_range 1-2)"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x64-macos ~x86-macos ~x86-solaris"

DESCRIPTION="PostgreSQL libraries and clients"
HOMEPAGE="http://www.postgresql.org/"
SRC_URI="mirror://postgresql/source/v${PV}/postgresql-${PV}.tar.bz2
		 http://dev.gentoo.org/~titanofold/postgresql-patches-${SLOT}.tbz2"
LICENSE="POSTGRESQL"

S=${WORKDIR}/postgresql-${PV}

# No tests to be done for clients and libraries
RESTRICT="test"

LINGUAS="af cs de es fa fr hr hu it ko nb pl pt_BR ro ru sk sl sv tr zh_CN zh_TW"
IUSE="doc kerberos nls pam readline ssl threads zlib ldap pg_legacytimestamp"

for lingua in ${LINGUAS} ; do
	IUSE+=" linguas_${lingua}"
done

wanted_languages() {
	local enable_langs

	for lingua in ${LINGUAS} ; do
		use linguas_${lingua} && enable_langs+="${lingua} "
	done

	echo -n ${enable_langs}
}

RDEPEND="kerberos? ( virtual/krb5 )
	pam? ( virtual/pam )
	readline? ( >=sys-libs/readline-4.1 )
	ssl? ( >=dev-libs/openssl-0.9.6-r1 )
	zlib? ( >=sys-libs/zlib-1.1.3 )
	>=app-admin/eselect-postgresql-0.3
	virtual/libintl
	!!dev-db/postgresql-libs
	!!dev-db/postgresql-client
	!!dev-db/libpq
	!!dev-db/postgresql
	ldap? ( net-nds/openldap )"
DEPEND="${RDEPEND}
	sys-devel/flex
	>=sys-devel/bison-1.875
	nls? ( sys-devel/gettext )"
PDEPEND="doc? ( ~dev-db/postgresql-docs-${PV} )"

src_prepare() {
	epatch "${WORKDIR}/autoconf.patch" \
		"${WORKDIR}/base.patch" \
		"${WORKDIR}/darwin.patch" \
		"${WORKDIR}/SuperH.patch"

	eprefixify src/include/pg_config_manual.h

	epatch "${FILESDIR}/postgresql-8.3-prefix.patch"
	eprefixify "${S}/src/include/pg_config_manual.h"

	# to avoid collision - it only should be installed by server
	rm "${S}/src/backend/nls.mk"

	# because psql/help.c includes the file
	ln -s "${S}/src/include/libpq/pqsignal.h" "${S}/src/bin/psql/"

	eautoconf
}

src_configure() {
	[[ ${CHOST} != *-linux-gnu ]] && append-libs -lintl
	export LDFLAGS_SL="${LDFLAGS}"
	econf --prefix=${EROOT%/}/usr/$(get_libdir)/postgresql-${SLOT} \
		--datadir=${EROOT%/}/usr/share/postgresql-${SLOT} \
		--docdir=${EROOT%/}/usr/share/doc/postgresql-${SLOT} \
		--sysconfdir=${EROOT%/}/etc/postgresql-${SLOT} \
		--includedir=${EROOT%/}/usr/include/postgresql-${SLOT} \
		--mandir=${EROOT%/}/usr/share/postgresql-${SLOT}/man \
		--enable-depend \
		--without-tcl \
		--without-perl \
		--without-python \
		$(use_with readline) \
		$(use_with kerberos krb5) \
		$(use_with kerberos gssapi) \
		"$(use_enable nls nls "$(wanted_languages)")" \
		$(use_with pam) \
		$(use_enable !pg_legacytimestamp integer-datetimes ) \
		$(use_with ssl openssl) \
		$(use_enable threads thread-safety) \
		$(use_with zlib) \
		$(use_with ldap) \
		|| die "configure failed"
}

src_compile() {
	emake || die "emake failed"

	cd "${S}/contrib"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	insinto /usr/include/postgresql-${SLOT}/postmaster
	doins "${S}"/src/include/postmaster/*.h
	dodir /usr/share/postgresql-${SLOT}/man/man1
	tar -zxf "${S}/doc/man.tar.gz" -C "${ED}"/usr/share/postgresql-${SLOT}/man man1/{ecpg,pg_config}.1

	rm -r "${ED}/usr/share/doc/postgresql-${SLOT}/html"
	rm "${ED}/usr/share/postgresql-${SLOT}/man/man1"/{initdb,pg_controldata,pg_ctl,pg_resetxlog,pg_restore,postgres,postmaster}.1 || die
	dodoc README HISTORY doc/{README.*,TODO,bug.template}

	cd "${S}/contrib"
	emake DESTDIR="${D}" install || die "emake install failed"
	cd "${S}"

	dodir /etc/eselect/postgresql/slots/${SLOT}

	IDIR="${EROOT%/}/usr/include/postgresql-${SLOT}"
	cat > "${ED}/etc/eselect/postgresql/slots/${SLOT}/base" <<-__EOF__
postgres_ebuilds="\${postgres_ebuilds} ${PF}"
postgres_prefix=${EROOT%/}/usr/$(get_libdir)/postgresql-${SLOT}
postgres_datadir=${EROOT%/}/usr/share/postgresql-${SLOT}
postgres_bindir=${EROOT%/}/usr/$(get_libdir)/postgresql-${SLOT}/bin
postgres_symlinks=(
	${IDIR} ${EROOT%/}/usr/include/postgresql
	${IDIR}/libpq-fe.h ${EROOT%/}/usr/include/libpq-fe.h
	${IDIR}/pg_config_manual.h ${EROOT%/}/usr/include/pg_config_manual.h
	${IDIR}/libpq ${EROOT%/}/usr/include/libpq
	${IDIR}/postgres_ext.h ${EROOT%/}/usr/include/postgres_ext.h
)
__EOF__

	cat >"${T}/50postgresql-94-${SLOT}" <<-__EOF__
		LDPATH=${EROOT%/}/usr/$(get_libdir)/postgresql-${SLOT}/$(get_libdir)
		MANPATH=${EROOT%/}/usr/share/postgresql-${SLOT}/man
	__EOF__
	doenvd "${T}/50postgresql-94-${SLOT}"

	keepdir /etc/postgresql-${SLOT}
}

pkg_postinst() {
	eselect postgresql update
	[[ "$(eselect postgresql show)" = "(none)" ]] && eselect postgresql set ${SLOT}
	elog "If you need a global psqlrc-file, you can place it in:"
	elog "    ${EROOT%/}/etc/postgresql-${SLOT}/"
}

pkg_postrm() {
	eselect postgresql update
}
