# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mysql.eclass,v 1.33 2006/08/31 21:37:03 chtekk Exp $

# Author: Francesco Riosa <vivo@gentoo.org>
# Maintainer: Luca Longinotti <chtekk@gentoo.org>

# Both MYSQL_VERSION_ID and MYSQL_PATCHSET_REV must be set in the ebuild too
# Note that MYSQL_VERSION_ID must be empty !!!

# MYSQL_VERSION_ID will be:
# major * 10e6 + minor * 10e4 + micro * 10e2 + gentoo revision number, all [0..99]
# This is an important part, because many of the choices the MySQL ebuild will do
# depend on this variable.
# In particular, the code below transforms a $PVR like "5.0.18-r3" in "5001803"

if [[ -z "${MYSQL_VERSION_ID}" ]] ; then
	tpv=( ${PV//[-._]/ } ) ; tpv[3]="${PVR:${#PV}}" ; tpv[3]="${tpv[3]##*-r}"
	for vatom in 0 1 2 3 ; do
		# pad to length 2
		tpv[${vatom}]="00${tpv[${vatom}]}"
		MYSQL_VERSION_ID="${MYSQL_VERSION_ID}${tpv[${vatom}]:0-2}"
	done
	# strip leading "0" (otherwise it's considered an octal number by BASH)
	MYSQL_VERSION_ID=${MYSQL_VERSION_ID##"0"}
fi

DEPEND="${DEPEND}
		>=sys-libs/readline-4.1
		berkdb? ( sys-apps/ed )
		ssl? ( >=dev-libs/openssl-0.9.6d )
		userland_GNU? ( sys-process/procps )
		>=sys-libs/zlib-1.2.3
		>=sys-apps/texinfo-4.7-r1
		>=sys-apps/sed-4"

RDEPEND="${DEPEND} selinux? ( sec-policy/selinux-mysql )"

# dev-perl/DBD-mysql is needed by some scripts installed by MySQL
PDEPEND="perl? ( >=dev-perl/DBD-mysql-2.9004 )"

inherit eutils flag-o-matic gnuconfig autotools mysql_fx

# Shorten the path because the socket path length must be shorter than 107 chars
# and we will run a mysql server during test phase
S="${WORKDIR}/${PN}"

# Define $MY_FIXED_PV for MySQL patchsets
MY_FIXED_PV="${PV/_alpha/}"
MY_FIXED_PV="${MY_FIXED_PV/_beta/}"
MY_FIXED_PV="${MY_FIXED_PV/_rc/}"

# Define correct SRC_URIs
SRC_URI="mirror://mysql/Downloads/MySQL-${PV%.*}/${P/_/-}${MYSQL_RERELEASE}.tar.gz"
if [[ -n "${MYSQL_PATCHSET_REV}" ]] ; then
	MYSQL_PATCHSET_FILENAME="${PN}-patchset-${MY_FIXED_PV}-r${MYSQL_PATCHSET_REV}.tar.bz2"
	# We add the Gentoo mirror here, as we only use primaryuri for the MySQL tarball
	SRC_URI="${SRC_URI} mirror://gentoo/${MYSQL_PATCHSET_FILENAME} http://gentoo.longitekk.com/${MYSQL_PATCHSET_FILENAME}"
fi

DESCRIPTION="A fast, multi-threaded, multi-user SQL database server."
HOMEPAGE="http://www.mysql.com/"
SLOT="0"
LICENSE="GPL-2"
IUSE="big-tables berkdb debug embedded minimal perl selinux srvdir ssl static"
RESTRICT="primaryuri confcache"

mysql_version_is_at_least "4.01.00.00" \
&& IUSE="${IUSE} latin1"

mysql_version_is_at_least "4.01.03.00" \
&& IUSE="${IUSE} cluster extraengine"

mysql_version_is_at_least "5.00.00.00" \
|| IUSE="${IUSE} raid"

mysql_version_is_at_least "5.00.18.00" \
&& IUSE="${IUSE} max-idx-128"

mysql_version_is_at_least "5.01.00.00" \
&& IUSE="${IUSE} innodb"

EXPORT_FUNCTIONS pkg_setup src_unpack src_compile src_install pkg_preinst \
				 pkg_postinst pkg_config pkg_postrm

# void mysql_init_vars()
#
# Initialize global variables
# 2005-11-19 <vivo@gentoo.org>

mysql_init_vars() {
	MY_SHAREDSTATEDIR=${MY_SHAREDSTATEDIR="/usr/share/mysql"}
	MY_SYSCONFDIR=${MY_SYSCONFDIR="/etc/mysql"}
	MY_LIBDIR=${MY_LIBDIR="/usr/$(get_libdir)/mysql"}
	MY_LOCALSTATEDIR=${MY_LOCALSTATEDIR="/var/lib/mysql"}
	MY_LOGDIR=${MY_LOGDIR="/var/log/mysql"}
	MY_INCLUDEDIR=${MY_INCLUDEDIR="/usr/include/mysql"}

	if [[ -z "${DATADIR}" ]] ; then
		DATADIR=""
		if [[ -f "${MY_SYSCONFDIR}/my.cnf" ]] ; then
			DATADIR=`"my_print_defaults" mysqld 2>/dev/null \
				| sed -ne '/datadir/s|^--datadir=||p' \
				| tail -n1`
			if [[ -z "${DATADIR}" ]] ; then
				if useq "srvdir" ; then
					DATADIR="${ROOT}/srv/localhost/mysql/datadir"
				else
					DATADIR=`grep ^datadir "${MY_SYSCONFDIR}/my.cnf" \
						| sed -e 's/.*=\s*//'`
				fi
			fi
		fi
		if [[ -z "${DATADIR}" ]] ; then
			if useq "srvdir" ; then
				DATADIR="${ROOT}/srv/localhost/mysql/datadir"
			else
				DATADIR="${MY_LOCALSTATEDIR}"
			fi
			einfo "Using default DATADIR"
		fi
		einfo "MySQL DATADIR is ${DATADIR}"

		if [[ -z "${PREVIOUS_DATADIR}" ]] ; then
			if [[ -e "${DATADIR}" ]] ; then
				ewarn "Previous datadir found, it's YOUR job to change"
				ewarn "ownership and take care of it"
				PREVIOUS_DATADIR="yes"
			else
				PREVIOUS_DATADIR="no"
			fi
			export PREVIOUS_DATADIR
		fi
	fi

	export MY_SHAREDSTATEDIR MY_SYSCONFDIR
	export MY_LIBDIR MY_LOCALSTATEDIR MY_LOGDIR
	export MY_INCLUDEDIR
	export DATADIR
}

mysql_pkg_setup() {
	enewgroup mysql 60 || die "problem adding 'mysql' group"
	enewuser mysql 60 -1 /dev/null mysql || die "problem adding 'mysql' user"

	# Check for USE flag problems in pkg_setup
	if useq "static" && useq "ssl" ; then
		eerror "MySQL does not support being built statically with SSL support enabled!"
		die "MySQL does not support being built statically with SSL support enabled!"
	fi

	if ! mysql_version_is_at_least "5.00.00.00" \
	&& useq "raid" \
	&& useq "static" ; then
		eerror "USE flags 'raid' and 'static' conflict, you cannot build MySQL statically"
		eerror "with RAID support enabled."
		die "USE flags 'raid' and 'static' conflict!"
	fi

	if mysql_version_is_at_least "4.01.03.00" \
	&& ( useq "cluster" || useq "extraengine" ) \
	&& useq "minimal" ; then
		eerror "USE flags 'cluster' and 'extraengine' conflict with 'minimal' USE flag!"
		die "USE flags 'cluster' and 'extraengine' conflict with 'minimal' USE flag!"
	fi
}

mysql_src_unpack() {
	# Initialize the proper variables first
	mysql_init_vars

	unpack ${A}

	mv -f "${WORKDIR}/${P/_/-}${MYSQL_RERELEASE}" "${S}"
	cd "${S}"

	# Apply the patches for this MySQL version
	if [[ -d "${WORKDIR}/${MY_FIXED_PV}" ]] ; then
		EPATCH_SOURCE="${WORKDIR}/${MY_FIXED_PV}" EPATCH_SUFFIX="patch" epatch
	fi

	# Additional checks, remove bundled zlib
	rm -f "${S}/zlib/"*.[ch]
	sed -i -e "s/zlib\/Makefile dnl/dnl zlib\/Makefile/" "${S}/configure.in"
	rm -f "scripts/mysqlbug"

	# Make charsets install in the right place
	find . -name 'Makefile.am' -exec sed --in-place -e 's!$(pkgdatadir)!'${MY_SHAREDSTATEDIR}'!g' {} \;

	# Manage mysqlmanager
	mysql_version_is_at_least "5.00.15.00" \
	&& sed -i -e "s!@GENTOO_EXT@!!g" -e "s!@GENTOO_SOCK_PATH@!var/run/mysqld!g" "${S}/server-tools/instance-manager/Makefile.am"

	if mysql_version_is_at_least "4.01.00.00" ; then
		# Remove what needs to be recreated, so we're sure it's actually done
		find . -name Makefile \
			-o -name Makefile.in \
			-o -name configure \
			-exec rm -f {} \;
		rm -f "ltmain.sh"
	fi

	local rebuilddirlist bdbdir d

	if mysql_version_is_at_least "5.01.00.00" ; then
		rebuilddirlist=". storage/innobase"
		bdbdir='storage/bdb/dist'
	else
		rebuilddirlist=". innobase"
		bdbdir='bdb/dist'
	fi

	for d in ${rebuilddirlist} ; do
		einfo "Reconfiguring dir '${d}'"
		pushd "${d}" &>/dev/null
		AT_GNUCONF_UPDATE="yes" eautoreconf
		popd &>/dev/null
	done

	# TODO: berkdb in MySQL 5.1 needs to be worked on
	if useq "berkdb" \
	&& ! mysql_check_version_range "4.00.00.00 to 4.00.99.99" \
	&& ! mysql_check_version_range "5.01.00.00 to 5.01.08.99" ; then
		[[ -w "${bdbdir}/ltmain.sh" ]] && cp -f "ltmain.sh" "${bdbdir}/ltmain.sh"
		pushd "${bdbdir}" \
		&& sh s_all \
		|| die "Failed bdb reconfigure" \
		&>/dev/null
		popd &>/dev/null
	fi
}

mysql_src_compile() {
	# Make sure the vars are correctly initialized
	mysql_init_vars

	local myconf

	if useq "static" ; then
		myconf="${myconf} --with-mysqld-ldflags=-all-static"
		myconf="${myconf} --with-client-ldflags=-all-static"
		myconf="${myconf} --disable-shared"
	else
		myconf="${myconf} --enable-shared --enable-static"
	fi

	myconf="${myconf} --without-libwrap"

	if useq "ssl" ; then
		# --with-vio is not needed anymore, it's on by default and
		# has been removed from configure
		mysql_version_is_at_least "5.00.04.00" || myconf="${myconf} --with-vio"
		if mysql_version_is_at_least "5.00.06.00" ; then
			# yassl-0.96 is still young and breaks with GCC-4.X or amd64
			# myconf="${myconf} --with-yassl"
			myconf="${myconf} --with-openssl"
		else
			myconf="${myconf} --with-openssl"
		fi
	else
		myconf="${myconf} --without-openssl"
	fi

	if useq "debug" ; then
		myconf="${myconf} --with-debug=full"
	else
		myconf="${myconf} --without-debug"

		mysql_version_is_at_least "4.01.03.00" && useq "cluster" \
		&& myconf="${myconf} --without-ndb-debug"
	fi

	# These are things we exclude from a minimal build.
	# Note that the server actually does get built and installed,
	# but we then delete it.
	local minimal_exclude_list="server embedded-server extra-tools innodb bench"

	if ! useq "minimal" ; then
		myconf="${myconf} --with-server"
		myconf="${myconf} --with-extra-tools"

		if ! mysql_version_is_at_least "5.00.00.00" ; then
			if useq "raid" ; then
				myconf="${myconf} --with-raid"
			else
				myconf="${myconf} --without-raid"
			fi
		fi

		if mysql_version_is_at_least "4.01.00.00" && ! useq "latin1" ; then
			myconf="${myconf} --with-charset=utf8"
			myconf="${myconf} --with-collation=utf8_general_ci"
		else
			myconf="${myconf} --with-charset=latin1"
			myconf="${myconf} --with-collation=latin1_swedish_ci"
		fi

		# Optional again with MySQL 5.1
		if mysql_version_is_at_least "5.01.00.00" ; then
			if useq "innodb" ; then
				myconf="${myconf} --with-innodb"
			else
				myconf="${myconf} --without-innodb"
			fi
		fi

		# Lots of charsets
		myconf="${myconf} --with-extra-charsets=all"

		# The following fix is due to a bug with bdb on SPARC's. See:
		# http://www.geocrawler.com/mail/msg.php3?msg_id=4754814&list=8
		# It comes down to non-64-bit safety problems.
		if useq "sparc" || useq "alpha" || useq "hppa" || useq "mips" || useq "amd64" ; then
			ewarn "bdb berkeley-db disabled due to incompatible arch"
			myconf="${myconf} --without-berkeley-db"
		else
			# TODO: berkdb in MySQL 5.1 needs to be worked on
			if useq "berkdb" && ! mysql_check_version_range "5.01.00.00 to 5.01.08.99" ; then
				myconf="${myconf} --with-berkeley-db=./bdb"
			else
				myconf="${myconf} --without-berkeley-db"
			fi
		fi

		if mysql_version_is_at_least "4.01.03.00" ; then
			myconf="${myconf} --with-geometry"

			if useq "cluster" ; then
				myconf="${myconf} --with-ndbcluster"
			else
				myconf="${myconf} --without-ndbcluster"
			fi
		fi

		if useq "big-tables" ; then
			myconf="${myconf} --with-big-tables"
		else
			myconf="${myconf} --without-big-tables"
		fi

		mysql_version_is_at_least "5.01.06.00" \
		&&  myconf="${myconf} --with-ndb-binlog"

		if useq "embedded" ; then
			myconf="${myconf} --with-embedded-privilege-control"
			myconf="${myconf} --with-embedded-server"
		else
			myconf="${myconf} --without-embedded-privilege-control"
			myconf="${myconf} --without-embedded-server"
		fi

		# Benchmarking stuff needs Perl
		if useq "perl" ; then
			myconf="${myconf} --with-bench"
		else
			myconf="${myconf} --without-bench"
		fi
	else
		for i in ${minimal_exclude_list} ; do
			myconf="${myconf} --without-${i}"
		done
		myconf="${myconf} --without-berkeley-db"
		myconf="${myconf} --with-extra-charsets=none"
	fi

	if mysql_version_is_at_least "4.01.03.00" && useq "extraengine" ; then
		# http://dev.mysql.com/doc/mysql/en/archive-storage-engine.html
		myconf="${myconf} --with-archive-storage-engine"

		# http://dev.mysql.com/doc/mysql/en/csv-storage-engine.html
		myconf="${myconf} --with-csv-storage-engine"

		# http://dev.mysql.com/doc/mysql/en/blackhole-storage-engine.html
		myconf="${myconf} --with-blackhole-storage-engine"

		# http://dev.mysql.com/doc/mysql/en/federated-storage-engine.html
		# http://dev.mysql.com/doc/mysql/en/federated-description.html
		# http://dev.mysql.com/doc/mysql/en/federated-limitations.html
		if mysql_version_is_at_least "5.00.03.00" ; then
			einfo "Before using the Federated storage engine, please be sure to read"
			einfo "http://dev.mysql.com/doc/mysql/en/federated-limitations.html"
			myconf="${myconf} --with-federated-storage-engine"
		fi

		# http://dev.mysql.com/doc/refman/5.1/en/partitioning-overview.html
		if mysql_version_is_at_least "5.01.00.00" ; then
			myconf="${myconf} --with-partition"
		fi
	fi

	mysql_version_is_at_least "5.00.18.00" \
	&& useq "max-idx-128" \
	&& myconf="${myconf} --with-max-indexes=128"

	mysql_version_is_at_least "5.01.05.00" \
	&& myconf="${myconf} --with-row-based-replication"

	# TODO: Rechek again later, there were problems with assembler enabled
	#       and some combination of USE flags with MySQL 5.1
	if mysql_check_version_range "5.01.00.00 to 5.01.08.99" ; then
		myconf="${myconf} --disable-assembler"
	else
		myconf="${myconf} --enable-assembler"
	fi

	# Bug #114895, bug #110149
	filter-flags "-O" "-O[01]"

	# glib-2.3.2_pre fix, bug #16496
	append-flags "-DHAVE_ERRNO_AS_DEFINE=1"

	# The compiler flags are as their "official" spec says ;)
	# CFLAGS="${CFLAGS/-O?/} -O3"
	export CXXFLAGS="${CXXFLAGS} -felide-constructors -fno-exceptions -fno-rtti"
	mysql_version_is_at_least "5.00.00.00" \
	&& export CXXFLAGS="${CXXFLAGS} -fno-implicit-templates"

	econf \
		--libexecdir="/usr/sbin" \
		--sysconfdir="${MY_SYSCONFDIR}" \
		--localstatedir="${MY_LOCALSTATEDIR}" \
		--sharedstatedir="${MY_SHAREDSTATEDIR}" \
		--libdir="${MY_LIBDIR}" \
		--includedir="${MY_INCLUDEDIR}" \
		--with-low-memory \
		--enable-local-infile \
		--with-mysqld-user=mysql \
		--with-client-ldflags=-lstdc++ \
		--enable-thread-safe-client \
		--with-comment="Gentoo Linux ${PF}" \
		--with-unix-socket-path="/var/run/mysqld/mysqld.sock" \
		--without-readline \
		--without-docs \
		${myconf} || die "bad ./configure"

	# TODO: Move this before autoreconf !!!
	find . -type f -name Makefile -print0 \
	| xargs -0 -n100 sed -i \
	-e 's|^pkglibdir *= *$(libdir)/mysql|pkglibdir = $(libdir)|;s|^pkgincludedir *= *$(includedir)/mysql|pkgincludedir = $(includedir)|'

	emake || die "compile problem"
}

mysql_src_install() {
	# Make sure the vars are correctly initialized
	mysql_init_vars

	make install DESTDIR="${D}" benchdir_root="${MY_SHAREDSTATEDIR}" || die "make install error"

	insinto "${MY_INCLUDEDIR}"
	doins "${MY_INCLUDEDIR}"/my_{config,dir}.h

	# Convenience links
	dosym "/usr/bin/mysqlcheck" "/usr/bin/mysqlanalyze"
	dosym "/usr/bin/mysqlcheck" "/usr/bin/mysqlrepair"
	dosym "/usr/bin/mysqlcheck" "/usr/bin/mysqloptimize"

	# Various junk (my-*.cnf moved elsewhere)
	rm -Rf "${D}/usr/share/info"
	for removeme in  "mysql-log-rotate" mysql.server* binary-configure* my-*.cnf mi_test_all* ; do
		rm -f "${D}"/usr/share/mysql/${removeme}
	done

	# Clean up stuff for a minimal build
	if useq "minimal" ; then
		rm -Rf "${D}${MY_SHAREDSTATEDIR}"/{mysql-test,sql-bench}
		rm -f "${D}"/usr/bin/{mysql{_install_db,manager*,_secure_installation,_fix_privilege_tables,hotcopy,_convert_table_format,d_multi,_fix_extensions,_zap,_explain_log,_tableinfo,d_safe,_install,_waitpid,binlog,test},myisam*,isam*,pack_isam}
		rm -f "${D}/usr/sbin/mysqld"
		rm -f "${D}${MY_LIBDIR}"/lib{heap,merge,nisam,my{sys,strings,sqld,isammrg,isam},vio,dbug}.a
	fi

	# Configuration stuff
	if mysql_version_is_at_least "4.01.00.00" ; then
		mysql_mycnf_version="4.1"
	else
		mysql_mycnf_version="4.0"
	fi
	insinto "${MY_SYSCONFDIR}"
	doins "scripts/mysqlaccess.conf"
	sed -e "s!@DATADIR@!${DATADIR}!g" \
		"${FILESDIR}/my.cnf-${mysql_mycnf_version}" \
		> "${TMPDIR}/my.cnf.ok"
	if mysql_version_is_at_least "4.01.00.00" && useq "latin1" ; then
		sed -e "s|utf8|latin1|g" -i "${TMPDIR}/my.cnf.ok"
	fi
	newins "${TMPDIR}/my.cnf.ok" my.cnf

	insinto "/etc/conf.d"
	newins "${FILESDIR}/mysql.conf.d" "mysql"
	mysql_version_is_at_least "5.00.11.00" \
	&& newins "${FILESDIR}/mysqlmanager.conf.d" "mysqlmanager"

	# Minimal builds don't have the MySQL server
	if ! useq "minimal" ; then
		exeinto "/etc/init.d"
		newexe "${FILESDIR}/mysql.rc6" "mysql"
		mysql_version_is_at_least "5.00.11.00" \
		&& newexe "${FILESDIR}/mysqlmanager.rc6" "mysqlmanager"

		insinto "/etc/logrotate.d"
		newins "${FILESDIR}/logrotate.mysql" "mysql"

		# Empty directories ...
		diropts "-m0750"
		if [[ "${PREVIOUS_DATADIR}" != "yes" ]] ; then
			dodir "${DATADIR}"
			keepdir "${DATADIR}"
			chown -R mysql:mysql "${D}/${DATADIR}"
		fi

		diropts "-m0755"
		for folder in "${MY_LOGDIR}" "/var/run/mysqld" ; do
			dodir "${folder}"
			keepdir "${folder}"
			chown -R mysql:mysql "${D}/${folder}"
		done
	fi

	# Docs
	dodoc README COPYING ChangeLog EXCEPTIONS-CLIENT INSTALL-SOURCE

	# Minimal builds don't have the MySQL server
	if ! useq "minimal" ; then
		docinto "support-files"
		for script in \
			support-files/my-*.cnf \
			support-files/magic \
			support-files/ndb-config-2-node.ini
		do
			dodoc "${script}"
		done

		docinto "scripts"
		for script in scripts/mysql* ; do
			[[ "${script%.sh}" == "${script}" ]] && dodoc "${script}"
		done
	fi

	ROOT="${D}" mysql_lib_symlinks
}

mysql_pkg_preinst() {
	enewgroup mysql 60 || die "problem adding 'mysql' group"
	enewuser mysql 60 -1 /dev/null mysql || die "problem adding 'mysql' user"
}

mysql_pkg_postinst() {
	# Make sure the vars are correctly initialized
	mysql_init_vars

	# Check FEATURES="collision-protect" before removing this
	[[ -d "${ROOT}/var/log/mysql" ]] || install -d -m0750 -o mysql -g mysql "${ROOT}${MY_LOGDIR}"

	# Secure the logfiles
	touch "${ROOT}${MY_LOGDIR}"/mysql.{log,err}
	chown mysql:mysql "${ROOT}${MY_LOGDIR}"/mysql*
	chmod 0660 "${ROOT}${MY_LOGDIR}"/mysql*

	if ! useq "minimal" ; then
		# Your friendly public service announcement ...
		einfo
		einfo "You might want to run:"
		einfo "\"emerge --config =${CATEGORY}/${PF}\""
		einfo "if this is a new install."
		einfo
		mysql_version_is_at_least "5.01.00.00" \
		|| einfo "InnoDB is *not* optional as of MySQL-4.0.24, at the request of upstream."
	fi
}

mysql_pkg_config() {
	# Make sure the vars are correctly initialized
	mysql_init_vars

	[[ -z "${DATADIR}" ]] && die "Sorry, unable to find DATADIR"

	if built_with_use dev-db/mysql minimal ; then
		die "Minimal builds do NOT include the MySQL server"
	fi

	local pwd1="a"
	local pwd2="b"
	local maxtry=5

	if [[ -d "${ROOT}/${DATADIR}/mysql" ]] ; then
		ewarn "You have already a MySQL database in place."
		ewarn "(${ROOT}/${DATADIR}/*)"
		ewarn "Please rename or delete it if you wish to replace it."
		die "MySQL database already exists!"
	fi

	einfo "Creating the mysql database and setting proper"
	einfo "permissions on it ..."

	einfo "Insert a password for the mysql 'root' user"
	ewarn "Avoid [\"'\\_%] characters in the password"
	read -rsp "    >" pwd1 ; echo

	einfo "Retype the password"
	read -rsp "    >" pwd2 ; echo

	if [[ "x$pwd1" != "x$pwd2" ]] ; then
		die "Passwords are not the same"
	fi

	local options=""
	local sqltmp="$(emktemp)"

	local help_tables="${ROOT}${MY_SHAREDSTATEDIR}/fill_help_tables.sql"
	[[ -r "${help_tables}" ]] \
	&& cp "${help_tables}" "${TMPDIR}/fill_help_tables.sql" \
	|| touch "${TMPDIR}/fill_help_tables.sql"
	help_tables="${TMPDIR}/fill_help_tables.sql"

	pushd "${TMPDIR}" &>/dev/null
	"${ROOT}/usr/bin/mysql_install_db" | grep -B5 -A999 -i "ERROR"
	popd &>/dev/null
	[[ -f "${ROOT}/${DATADIR}/mysql/user.frm" ]] \
	|| die "MySQL databases not installed"
	chown -R mysql:mysql "${ROOT}/${DATADIR}" 2> /dev/null
	chmod 0750 "${ROOT}/${DATADIR}" 2> /dev/null

	if mysql_version_is_at_least "4.01.03.00" ; then
		options="--skip-ndbcluster"

		# Filling timezones, see
		# http://dev.mysql.com/doc/mysql/en/time-zone-support.html
		"${ROOT}/usr/bin/mysql_tzinfo_to_sql" "${ROOT}/usr/share/zoneinfo" > "${sqltmp}" 2>/dev/null

		if [[ -r "${help_tables}" ]] ; then
			cat "${help_tables}" >> "${sqltmp}"
		fi
	fi

	local socket="${ROOT}/var/run/mysqld/mysqld${RANDOM}.sock"
	local pidfile="${ROOT}/var/run/mysqld/mysqld${RANDOM}.pid"
	local mysqld="${ROOT}/usr/sbin/mysqld \
		${options} \
		--user=mysql \
		--skip-grant-tables \
		--basedir=${ROOT}/usr \
		--datadir=${ROOT}/${DATADIR} \
		--skip-innodb \
		--skip-bdb \
		--skip-networking \
		--max_allowed_packet=8M \
		--net_buffer_length=16K \
		--socket=${socket} \
		--pid-file=${pidfile}"
	${mysqld} &
	while ! [[ -S "${socket}" || "${maxtry}" -lt 1 ]] ; do
		maxtry=$((${maxtry}-1))
		echo -n "."
		sleep 1
	done

	# Do this from memory, as we don't want clear text passwords in temp files
	local sql="UPDATE mysql.user SET Password = PASSWORD('${pwd1}') WHERE USER='root'"
	"${ROOT}/usr/bin/mysql" \
		--socket=${socket} \
		-hlocalhost \
		-e "${sql}"

	einfo "Loading \"zoneinfo\", this step may require a few seconds ..."

	"${ROOT}/usr/bin/mysql" \
		--socket=${socket} \
		-hlocalhost \
		-uroot \
		-p"${pwd1}" \
		mysql < "${sqltmp}"

	# Stop the server and cleanup
	kill $(< "${pidfile}" )
	rm -f "${sqltmp}"
	einfo "Stopping the server ..."
	wait %1
	einfo "Done"
}

mysql_pkg_postrm() {
	mysql_lib_symlinks
}
