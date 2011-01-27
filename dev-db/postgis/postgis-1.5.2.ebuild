# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/postgis/postgis-1.5.2.ebuild,v 1.1 2010/09/28 10:26:05 patrick Exp $

EAPI="2"

inherit eutils versionator

DESCRIPTION="Geographic Objects for PostgreSQL"
HOMEPAGE="http://postgis.refractions.net"
SRC_URI="http://postgis.refractions.net/download/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="doc"

RDEPEND=">=dev-db/postgresql-server-8.3
	>=sci-libs/geos-3.2
	>=sci-libs/proj-4.6.0
	dev-libs/libxml2"

DEPEND="${RDEPEND}
	doc? ( app-text/docbook-xsl-stylesheets
		app-text/docbook-xml-dtd:4.3
		media-gfx/imagemagick )"

RESTRICT="test"

pkg_setup(){
	if [ ! -z "${PGUSER}" ]; then
		eval unset PGUSER
	fi
	if [ ! -z "${PGDATABASE}" ]; then
		eval unset PGDATABASE
	fi
	local tmp
	tmp="$(portageq match / ${CATEGORY}/${PN} | cut -d'.' -f2)"
	if [ "${tmp}" != "$(get_version_component_range 2)" ]; then
		elog "You must soft upgrade your existing postgis enabled databases"
		elog "by adding their names in the ${EROOT}conf.d/postgis_dbs file"
		elog "then using 'emerge --config postgis'."
		require_soft_upgrade="1"
		ebeep 2
	fi
}

src_configure(){
	local myconf
	if use doc; then
		myconf="${myconf} --with-xsldir=$(ls "${EROOT}"usr/share/sgml/docbook/* | \
			grep xsl\- | cut -d':' -f1)"
	fi

	econf --enable-autoconf \
		--datadir="${EPREFIX}"/usr/share/postgresql/contrib/ \
		--libdir="${EPREFIX}"/usr/$(get_libdir)/postgresql/ \
		--docdir="${ED}/usr/share/doc/${PF}/html/" \
		${myconf} ||\
			die "Error: econf failed"

	if use doc; then
		cd doc
		sed -i -e 's:PGSQL_DOCDIR=/:PGSQL_DOCDIR=${ED}/:' Makefile || die "Fixing doc install paths failed"
		sed -i -e 's:PGSQL_MANDIR=/:PGSQL_MANDIR=${ED}/:' Makefile || die "Fixing doc install paths failed"
		sed -i -e 's:PGSQL_SHAREDIR=/:PGSQL_SHAREDIR=${ED}/:' Makefile || die "Fixing doc install paths failed"
	fi
}

src_compile() {
	emake -j1 || die "Error: emake failed"

	cd topology/
	emake -j1 || die "Unable to build topology sql file"

	if use doc ; then
		cd "${S}"
		emake -j1 docs || die "Unable to build documentation"
	fi
}

src_install(){
	dodir /usr/$(get_libdir)/postgresql /usr/share/postgresql/contrib/
	emake DESTDIR="${D}" install || die "emake install failed"
	cd "${S}/topology/"
	emake DESTDIR="${D}" install || die "emake install topology failed"

	cd "${S}"
	dodoc CREDITS TODO loader/README.* doc/*txt

	docinto topology
	dodoc topology/{TODO,README}
	dobin ./utils/postgis_restore.pl

	cd "${S}"
	if use doc; then
		emake DESTDIR="${D}" docs-install || die "emake install docs failed"
	fi

	echo "template_gis" > postgis_dbs
	doconfd postgis_dbs

	if [ ! -z "${require_soft_upgrade}" ]; then
		grep "'C'" -B 4 "${ED}"usr/share/postgresql/contrib/lwpostgis.sql | \
			grep -v "'sql'" > \
				"${ED}"usr/share/postgresql/contrib/load_before_upgrade.sql
	fi
}

pkg_postinst() {
	elog "To create new (upgrade) spatial databases add their names in the"
	elog "${EROOT}conf.d/postgis_dbs file, then use 'emerge --config postgis'."
}

pkg_config(){
	einfo "Create or upgrade a spatial templates and databases."
	einfo "Please add your databases names into ${EROOT}conf.d/postgis_dbs"
	einfo "(templates name have to be prefixed with 'template')."
	for i in $(cat "${EROOT}etc/conf.d/postgis_dbs"); do
		source "${EROOT}"etc/conf.d/postgresql
		PGDATABASE=${i}
		eval set PGDATABASE=${i}
		myuser="${PGUSER:-postgres}"
		mydb="${PGDATABASE:-template_gis}"
		eval set PGUSER=${myuser}

		is_template=false
		if [ "${mydb:0:8}" == "template" ];then
			is_template=true
			mytype="template database"
		else
			mytype="database"
		fi

		einfo
		einfo "Using the user ${myuser} and the ${mydb} ${mytype}."

		logfile=$(mktemp "${EROOT}tmp/error.log.XXXXXX")
		safe_exit(){
			eerror "Removing created ${mydb} ${mytype}"
			dropdb -q -U "${myuser}" "${mydb}" ||\
				(eerror "${1}"
				die "Removing old db failed, you must do it manually")
			eerror "Please read ${logfile} for more information."
			die "${1}"
		}

	# if there is not a table or a template existing with the same name, create.
		if [ -z "$(psql -U ${myuser} -l | grep "${mydb}")" ]; then
			createdb -q -O ${myuser} -U ${myuser} ${mydb} ||\
				die "Unable to create the ${mydb} ${mytype} as ${myuser}"
			createlang -U ${myuser} plpgsql ${mydb}
			if [ "$?" == 2 ]; then
				safe_exit "Unable to createlang plpgsql ${mydb}."
			fi
			(psql -q -U ${myuser} ${mydb} -f \
				"${EROOT}"usr/share/postgresql/contrib/lwpostgis.sql &&
			psql -q -U ${myuser} ${mydb} -f \
				"${EROOT}"usr/share/postgresql/contrib/spatial_ref_sys.sql) 2>\
					"${logfile}"
			if [ "$(grep -c ERROR "${logfile}")" \> 0 ]; then
				safe_exit "Unable to load sql files."
			fi
			if ${is_template}; then
				psql -q -U ${myuser} ${mydb} -c \
					"UPDATE pg_database SET datistemplate = TRUE
					WHERE datname = '${mydb}';
			GRANT ALL ON table spatial_ref_sys, geometry_columns TO PUBLIC;" \
				|| die "Unable to create ${mydb}"
			psql -q -U ${myuser} ${mydb} -c \
				"VACUUM FREEZE;" || die "Unable to set VACUUM FREEZE option"
			fi
		else
			if [ -e "${EROOT}"usr/share/postgresql/contrib/load_before_upgrade.sql ];
			then
				einfo "Updating the dynamic library references"
				psql -q -f \
					"${EROOT}"usr/share/postgresql/contrib/load_before_upgrade.sql\
						2> "${logfile}"
				if [ "$(grep -c ERROR "${logfile}")" \> 0 ]; then
					safe_exit "Unable to update references."
				fi
			fi
			if [ -e "${EROOT}"usr/share/postgresql/contrib/lwpostgis_upgrade.sql ];
			then
				einfo "Running soft upgrade"
				psql -q -U ${myuser} ${mydb} -f \
					"${EROOT}"usr/share/postgresql/contrib/lwpostgis_upgrade.sql 2>\
						"${logfile}"
				if [ "$(grep -c ERROR "${logfile}")" \> 0 ]; then
					safe_exit "Unable to run soft upgrade."
				fi
			fi
		fi
		if ${is_template}; then
			einfo "You can now create a spatial database using :"
			einfo "'createdb -T ${mydb} test'"
		fi
	done
}
