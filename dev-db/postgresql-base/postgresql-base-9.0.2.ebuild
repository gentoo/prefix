# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/postgresql-base/postgresql-base-9.0.2.ebuild,v 1.1 2011/01/04 19:22:51 patrick Exp $

EAPI="2"

WANT_AUTOMAKE="none"

inherit eutils multilib versionator autotools prefix flag-o-matic

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x64-macos ~x86-macos ~x86-solaris"

DESCRIPTION="PostgreSQL libraries and clients"
HOMEPAGE="http://www.postgresql.org/"

MY_PV=${PV/_/}
SRC_URI="mirror://postgresql/source/v${MY_PV}/postgresql-${MY_PV}.tar.bz2"
S=${WORKDIR}/postgresql-${MY_PV}

LICENSE="POSTGRESQL"
SLOT="$(get_version_component_range 1-2)"
LINGUAS="af cs de es fa fr hr hu it ko nb pl pt_BR ro ru sk sl sv tr zh_CN zh_TW"
IUSE="doc kerberos ldap nls pam pg_legacytimestamp readline ssl threads zlib"

for lingua in ${LINGUAS}; do
	IUSE+=" linguas_${lingua}"
done

RESTRICT="test"

wanted_languages() {
	local enable_langs

	for lingua in ${LINGUAS} ; do
		use linguas_${lingua} && enable_langs+="${lingua} "
	done

	echo -n ${enable_langs}
}

RDEPEND="!!dev-db/postgresql-libs
	!!dev-db/postgresql-client
	!!dev-db/libpq
	!!dev-db/postgresql
	>=app-admin/eselect-postgresql-0.3
	virtual/libintl
	kerberos? ( virtual/krb5 )
	ldap? ( net-nds/openldap )
	pam? ( virtual/pam )
	readline? ( sys-libs/readline )
	ssl? ( >=dev-libs/openssl-0.9.6-r1 )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}
	sys-devel/bison
	sys-devel/flex
	nls? ( sys-devel/gettext )"
PDEPEND="doc? ( ~dev-db/postgresql-docs-${PV} )"

src_prepare() {
	epatch "${FILESDIR}/postgresql-9.0-common.3.patch" \
		"${FILESDIR}/postgresql-${SLOT}-base.3.patch" \
		"${FILESDIR}/postgresql-8.3-prefix.patch"

	eprefixify "${S}/src/include/pg_config_manual.h"

	# to avoid collision - it only should be installed by server
	rm "${S}/src/backend/nls.mk"

	# because psql/help.c includes the file
	ln -s "${S}/src/include/libpq/pqsignal.h" "${S}/src/bin/psql/" || die

	eautoconf
}

src_configure() {
	[[ ${CHOST} != *-linux-gnu ]] && append-libs -lintl
	export LDFLAGS_SL="${LDFLAGS}"
	econf \
		--prefix="${EPREFIX}"/usr/$(get_libdir)/postgresql-${SLOT} \
		--datadir="${EPREFIX}"/usr/share/postgresql-${SLOT} \
		--docdir="${EPREFIX}"/usr/share/doc/postgresql-${SLOT} \
		--sysconfdir="${EPREFIX}"/etc/postgresql-${SLOT} \
		--includedir="${EPREFIX}"/usr/include/postgresql-${SLOT} \
		--mandir="${EPREFIX}"/usr/share/postgresql-${SLOT}/man \
		--enable-depend \
		--without-tcl \
		--without-perl \
		--without-python \
		$(use_with readline) \
		$(use_with kerberos krb5) \
		$(use_with kerberos gssapi) \
		"$(use_enable nls nls "$(wanted_languages)")" \
		$(use_with pam) \
		$(use_enable !pg_legacytimestamp integer-datetimes) \
		$(use_with ssl openssl) \
		$(use_enable threads thread-safety) \
		$(use_with zlib) \
		$(use_with ldap)
}

src_compile() {
	emake || die "emake failed"

	cd "${S}/contrib"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	insinto /usr/include/postgresql-${SLOT}/postmaster
	doins "${S}"/src/include/postmaster/*.h || die

	dodir /usr/share/postgresql-${SLOT}/man/man1/ || die
	cp  "${S}"/doc/src/sgml/man1/* "${ED}"/usr/share/postgresql-${SLOT}/man/man1/ || die

	rm "${ED}/usr/share/postgresql-${SLOT}/man/man1"/{initdb,ipcclean,pg_controldata,pg_ctl,pg_resetxlog,pg_restore,postgres,postmaster}.1
	dodoc README HISTORY doc/{README.*,TODO,bug.template} || die

	cd "${S}/contrib"
	emake DESTDIR="${D}" install || die "emake install failed"
	cd "${S}"

	dodir /etc/eselect/postgresql/slots/${SLOT} || die

	IDIR="${EPREFIX}/usr/include/postgresql-${SLOT}"
	cat > "${ED}/etc/eselect/postgresql/slots/${SLOT}/base" <<-__EOF__
postgres_ebuilds="\${postgres_ebuilds} ${PF}"
postgres_prefix="${EPREFIX}/usr/$(get_libdir)/postgresql-${SLOT}"
postgres_datadir="${EPREFIX}/usr/share/postgresql-${SLOT}"
postgres_bindir="${EPREFIX}/usr/$(get_libdir)/postgresql-${SLOT}/bin"
postgres_symlinks=(
	${IDIR} "${EPREFIX}/usr/include/postgresql"
	${IDIR}/libpq-fe.h "${EPREFIX}/usr/include/libpq-fe.h"
	${IDIR}/pg_config_manual.h /usr/include/pg_config_manual.h
	${IDIR}/libpq "${EPREFIX}/usr/include/libpq"
	${IDIR}/postgres_ext.h "${EPREFIX}/usr/include/postgres_ext.h"
)
__EOF__

	cat >"${T}/50postgresql-94-${SLOT}" <<-__EOF__
LDPATH=${EPREFIX}/usr/$(get_libdir)/postgresql-${SLOT}/$(get_libdir)
MANPATH=${EPREFIX}/usr/share/postgresql-${SLOT}/man
__EOF__
	doenvd "${T}/50postgresql-94-${SLOT}" || die

	keepdir /etc/postgresql-${SLOT} || die
}

pkg_postinst() {
	eselect postgresql update
	[[ "$(eselect postgresql show)" = "(none)" ]] && eselect postgresql set ${SLOT}
	elog "If you need a global psqlrc-file, you can place it in:"
	elog "    '${EROOT}/etc/postgresql-${SLOT}/'"
	elog
}

pkg_postrm() {
	eselect postgresql update
}
