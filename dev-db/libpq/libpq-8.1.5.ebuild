# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/libpq/libpq-8.1.5.ebuild,v 1.2 2006/11/09 17:48:09 chtekk Exp $

EAPI="prefix"

inherit eutils gnuconfig flag-o-matic toolchain-funcs

KEYWORDS="~amd64"

DESCRIPTION="PostgreSQL libraries."
HOMEPAGE="http://www.postgresql.org/"
SRC_URI="mirror://postgresql/source/v${PV}/postgresql-base-${PV}.tar.bz2
		mirror://postgresql/source/v${PV}/postgresql-opt-${PV}.tar.bz2"
LICENSE="POSTGRESQL"
SLOT="4"
IUSE="kerberos nls pam pg-intdatetime readline ssl threads zlib"

RDEPEND="!<=dev-db/postgresql-8.1.4
		kerberos? ( virtual/krb5 )
		pam? ( virtual/pam )
		readline? ( >=sys-libs/readline-4.1 )
		ssl? ( >=dev-libs/openssl-0.9.6-r1 )
		zlib? ( >=sys-libs/zlib-1.1.3 )"
DEPEND="${RDEPEND}
		sys-devel/autoconf
		>=sys-devel/bison-1.875
		nls? ( sys-devel/gettext )"

S="${WORKDIR}/postgresql-${PV}"

pkg_preinst() {
	# Removing wrong symlink created by previous ebuild
	if [[ -L "${EROOT}/usr/include/libpq" ]] ; then
		rm -f "${EROOT}/usr/include/libpq"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-${PV}-gentoo.patch"
}

src_compile() {
	filter-flags -ffast-math -feliminate-dwarf2-dups

	# Detect mips systems properly
	gnuconfig_update

	cd "${S}"

	./configure --prefix="${EPREFIX}"/usr \
		--includedir="${EPREFIX}"/usr/include/postgresql/libpq-${SLOT} \
		--sysconfdir="${EPREFIX}"/etc/postgresql \
		--mandir="${EPREFIX}"/usr/share/man \
		--host=${CHOST} \
		--with-docdir="${EPREFIX}"/usr/share/doc/${PF} \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--enable-depend \
		$(use_with kerberos krb5) \
		$(use_enable nls ) \
		$(use_with pam) \
		--without-perl \
		$(use_enable pg-intdatetime integer-datetimes ) \
		--without-python \
		$(use_with readline) \
		$(use_with ssl openssl) \
		--without-tcl \
		$(use_enable threads thread-safety ) \
		$(use_with zlib) \
		|| die "configure failed"

	cd "${S}/src/interfaces/libpq"
	emake -j1 LD="$(tc-getLD) $(get_abi_LDFLAGS)" || die "emake libpq failed"

	cd "${S}/src/bin/pg_config"
	emake -j1 LD="$(tc-getLD) $(get_abi_LDFLAGS)" || die "emake pg_config failed"
}

src_install() {
	cd "${S}/src/interfaces/libpq"
	emake DESTDIR="${D}" LIBDIR="${D}/usr/$(get_libdir)" install || die "emake install libpq failed"

	cd "${S}/src/include"
	emake DESTDIR="${D}" install || die "emake install headers failed"

	cd "${S}/src/bin/pg_config"
	emake DESTDIR="${D}" install || die "emake install pg_config failed"

	cd "${S}"
	dodoc README HISTORY

	dosym libpq-${SLOT}.a /usr/$(get_libdir)/libpq.a

	for f in $(ls -1 "${ED}"/usr/include/postgresql/libpq-${SLOT}/*.h) ; do
		dosym postgresql/libpq-${SLOT}/$(basename ${f}) /usr/include/
	done

	dodir /usr/include/libpq
	for f in $(ls -1 "${ED}"/usr/include/postgresql/libpq-${SLOT}/libpq/*.h) ; do
		dosym ../postgresql/libpq-${SLOT}/libpq/$(basename ${f}) /usr/include/libpq/
	done

	cd "${ED}/usr/include/postgresql/libpq-${SLOT}"
	for f in $(find * -name '*.h' -print) ; do
		destdir=$(dirname ${f})
		if [[ ! -d "${ED}/usr/include/postgresql/${destdir}" ]] ; then
			dodir "/usr/include/postgresql/${destdir}"
		fi
		dosym /usr/include/postgresql/libpq-${SLOT}/${f} "/usr/include/postgresql/${destdir}/"
	done
}

src_test() {
	einfo "No tests available for libpq."
}
