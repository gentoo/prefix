# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/postgresql/postgresql-8.1.8.ebuild,v 1.1 2007/02/12 03:34:18 mjolnir Exp $

EAPI="prefix"

inherit eutils gnuconfig flag-o-matic multilib toolchain-funcs versionator

KEYWORDS="~amd64 ~x86 ~x86-solaris"

DESCRIPTION="Sophisticated and powerful Object-Relational DBMS."
HOMEPAGE="http://www.postgresql.org/"
SRC_URI="mirror://postgresql/source/v${PV}/${PN}-base-${PV}.tar.bz2
		mirror://postgresql/source/v${PV}/${PN}-opt-${PV}.tar.bz2
		doc? ( mirror://postgresql/source/v${PV}/${PN}-docs-${PV}.tar.bz2 )
		test? ( mirror://postgresql/source/v${PV}/${PN}-test-${PV}.tar.bz2 )"
LICENSE="POSTGRESQL"
SLOT="0"
IUSE="doc kerberos nls pam perl pg-intdatetime python readline selinux ssl tcl test xml zlib"

RDEPEND="~dev-db/libpq-${PV}
		>=sys-libs/ncurses-5.2
		kerberos? ( virtual/krb5 )
		pam? ( virtual/pam )
		perl? ( >=dev-lang/perl-5.6.1-r2 )
		python? ( >=dev-lang/python-2.2 dev-python/egenix-mx-base )
		readline? ( >=sys-libs/readline-4.1 )
		selinux? ( sec-policy/selinux-postgresql )
		ssl? ( >=dev-libs/openssl-0.9.6-r1 )
		tcl? ( >=dev-lang/tcl-8 )
		xml? ( dev-libs/libxml2 dev-libs/libxslt )
		zlib? ( >=sys-libs/zlib-1.1.3 )"
DEPEND="${RDEPEND}
		sys-devel/autoconf
		>=sys-devel/bison-1.875
		nls? ( sys-devel/gettext )
		xml? ( dev-util/pkgconfig )"

PG_DIR="${EPREFIX}/var/lib/postgresql"
[[ -z "${PG_MAX_CONNECTIONS}" ]] && PG_MAX_CONNECTIONS="512"

pkg_setup() {
	if [[ -f "${PG_DIR}/data/PG_VERSION" ]] ; then
		if [[ $(cat "${PG_DIR}/data/PG_VERSION") != $(get_version_component_range 1-2) ]] ; then
			eerror "PostgreSQL ${PV} cannot upgrade your existing databases, you must"
			eerror "use pg_dump to export your existing databases to a file, and then"
			eerror "pg_restore to import them when you have upgraded completely."
			eerror "You must remove your entire database directory to continue."
			eerror "(database directory = ${PG_DIR})."
			die "Remove your database directory to continue"
		fi
	fi
	enewgroup postgres 70
	enewuser postgres 70 /bin/bash /var/lib postgres
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-${PV}-gentoo.patch"
	epatch "${FILESDIR}/${PN}-${PV}-sh.patch"

	# Prepare package for future tests
	if use test ; then
		# Fix sandbox violation
		sed -e "s|/no/such/location|${S}/src/test/regress/tmp_check/no/such/location|g" -i src/test/regress/{input,output}/tablespace.source

		# Fix broken tests
		epatch "${FILESDIR}/${PN}-${PV}-regress_fix.patch"

		# We need to run the tests as a non-root user, portage seems the most fitting here,
		# so if userpriv is enabled, we use it directly. If userpriv is disabled, we need to
		# su - to a valid user, portage again, so we patch the test-scripts to do that.
		mkdir -p "${S}/src/test/regress/tmp_check"
		chown portage "${S}/src/test/regress/tmp_check"
		einfo "Tests will be run as user portage."
		if ! hasq userpriv ${FEATURES} ; then
			mkdir -p "${S}/src/test/regress/results"
			chown portage "${S}/src/test/regress/results"
			epatch "${FILESDIR}/${PN}-${PV}-regress_su.patch"
			sed -e "s|PORTAGETEMPDIRPG|${S}/src/test/regress|g" -i src/test/regress/pg_regress.sh
		fi
	fi
}

src_compile() {
	filter-flags -ffast-math -feliminate-dwarf2-dups

	# Detect mips systems properly
	gnuconfig_update

	# maybe this is for all non-GNU libc babies...
	[[ ${CHOST} == *-solaris* ]] && use nls && append-ldflags -lintl

	cd "${S}"

	./configure --prefix="${EPREFIX}"/usr \
		--includedir="${EPREFIX}"/usr/include/postgresql/pgsql \
		--sysconfdir="${EPREFIX}"/etc/postgresql \
		--mandir="${EPREFIX}"/usr/share/man \
		--host=${CHOST} \
		--with-docdir="${EPREFIX}"/usr/share/doc/${PF} \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--enable-depend \
		$(use_with kerberos krb5) \
		$(use_enable nls ) \
		$(use_with pam) \
		$(use_with perl) \
		$(use_enable pg-intdatetime integer-datetimes ) \
		$(use_with python) \
		$(use_with readline) \
		$(use_with ssl openssl) \
		$(use_with tcl) \
		$(use_with zlib) \
		|| die "configure failed"

	emake -j1 LD="$(tc-getLD) $(get_abi_LDFLAGS)" || die "main emake failed"

	cd "${S}/contrib"
	emake -j1 LD="$(tc-getLD) $(get_abi_LDFLAGS)" || die "contrib emake failed"

	if use xml ; then
		cd "${S}/contrib/xml2"
		emake -j1 LD="$(tc-getLD) $(get_abi_LDFLAGS)" || die "contrib/xml2 emake failed"
	fi
}

src_install() {
	if use perl ; then
		mv -f "${S}/src/pl/plperl/GNUmakefile" "${S}/src/pl/plperl/GNUmakefile_orig"
		sed -e "s:\$(DESTDIR)\$(plperl_installdir):\$(plperl_installdir):" \
			"${S}/src/pl/plperl/GNUmakefile_orig" > "${S}/src/pl/plperl/GNUmakefile"
	fi

	cd "${S}"
	emake -j1 DESTDIR="${D}" LIBDIR="${ED}/usr/$(get_libdir)" install || die "main emake install failed"

	cd "${S}/contrib"
	emake -j1 DESTDIR="${D}" LIBDIR="${ED}/usr/$(get_libdir)" install || die "contrib emake install failed"

	if use xml ; then
		cd "${S}/contrib/xml2"
		emake -j1 DESTDIR="${D}" LIBDIR="${ED}/usr/$(get_libdir)" install || die "contrib/xml2 emake install failed"
	fi

	cd "${S}"
	dodoc README HISTORY
	dodoc contrib/adddepend/*

	cd "${S}/doc"
	dodoc FAQ* README.* TODO bug.template

	if use doc ; then
		cd "${S}/doc"
		docinto FAQ_html
		dodoc src/FAQ/*
		docinto sgml
		dodoc src/sgml/*.{sgml,dsl}
		docinto sgml/ref
		dodoc src/sgml/ref/*.sgml
		docinto TODO.detail
		dodoc TODO.detail/*
	fi

	newinitd "${FILESDIR}/postgresql.init-${PV%.*}" postgresql || die "Inserting init.d-file failed"
	newconfd "${FILESDIR}/postgresql.conf-${PV%.*}" postgresql || die "Inserting conf.d-file failed"
}

pkg_postinst() {
	elog "Execute the following command to setup the initial database environment:"
	elog
	elog "emerge --config =${PF}"
	elog
	elog "The autovacuum function, which was in contrib, has been moved to the main"
	elog "PostgreSQL functions starting with 8.1."
	elog "You can enable it in ${EROOT}/etc/postgresql/postgresql.conf."
	elog
	elog "If you need a global psqlrc-file, you can place it in '${EROOT}/etc/postgresql/'."
}

pkg_config() {
	einfo "Creating the data directory ..."
	mkdir -p "${PG_DIR}/data"
	chown -Rf postgres:postgres "${PG_DIR}"
	chmod 0700 "${PG_DIR}/data"

	local supostgres=""
	[[ ${EPREFIX%/} == "" ]] && supostgres="su postgres -c"

	einfo "Initializing the database ..."
	if [[ -f "${PG_DIR}/data/PG_VERSION" ]] ; then
		eerror "PostgreSQL ${PV} cannot upgrade your existing databases."
		eerror "You must remove your entire database directory to continue."
		eerror "(database directory = ${PG_DIR})."
		die "Remove your database directory to continue"
	else
		if use kernel_linux ; then
			local SEM=`sysctl -n kernel.sem | cut -f-3`
			local SEMMNI=`sysctl -n kernel.sem | cut -f4`
			local SEMMNI_MIN=`expr \( ${PG_MAX_CONNECTIONS} + 15 \) / 16`
			local SHMMAX=`sysctl -n kernel.shmmax`
			local SHMMAX_MIN=`expr 500000 + 30600 \* ${PG_MAX_CONNECTIONS}`

			if [ ${SEMMNI} -lt ${SEMMNI_MIN} ] ; then
				eerror "The current value of SEMMNI is too low"
				eerror "for PostgreSQL to run ${PG_MAX_CONNECTIONS} connections!"
				eerror "Temporary setting this value to ${SEMMNI_MIN} while creating the initial database."
				echo ${SEM} ${SEMMNI_MIN} > /proc/sys/kernel/sem
			fi

			${supostgres} "${EPREFIX}/usr/bin/initdb --pgdata ${PG_DIR}/data"

			if [ ! `sysctl -n kernel.sem | cut -f4` -eq ${SEMMNI} ] ; then
				echo ${SEM} ${SEMMNI} > /proc/sys/kernel/sem
				ewarn "Restoring the SEMMNI value to the previous value."
				ewarn "Please edit the last value of kernel.sem in /etc/sysctl.conf"
				ewarn "and set it to at least ${SEMMNI_MIN}:"
				ewarn
				ewarn "  kernel.sem = ${SEM} ${SEMMNI_MIN}"
				ewarn
			fi

			if [ ${SHMMAX} -lt ${SHMMAX_MIN} ] ; then
				eerror "The current value of SHMMAX is too low for postgresql to run."
				eerror "Please edit /etc/sysctl.conf and set this value to at least ${SHMMAX_MIN}:"
				eerror
				eerror "  kernel.shmmax = ${SHMMAX_MIN}"
				eerror
			fi
		else
			${supostgres} "${EPREFIX}/usr/bin/initdb --pgdata ${PG_DIR}/data"
		fi

		einfo
		einfo "You can use the '${EROOT}/etc/init.d/postgresql' script to run PostgreSQL instead of 'pg_ctl'."
		einfo
	fi
}

src_test() {
	cd "${S}"

	einfo ">>> Test phase [check]: ${CATEGORY}/${PF}"
	if ! emake -j1 check ; then
		hasq test ${FEATURES} && die "Make check failed. See above for details."
		hasq test ${FEATURES} || eerror "Make check failed. See above for details."
	fi

	einfo "Yes, there are other tests which could be run."
	einfo "... and no, we don't plan to add/support them."
	einfo "For now, the main regressions tests will suffice."
	einfo "If you think other tests are necessary, please submit a"
	einfo "bug including a patch for this ebuild to enable them."
}
