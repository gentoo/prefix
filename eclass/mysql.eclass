# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mysql.eclass,v 1.53 2007/01/01 22:27:01 swegener Exp $

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

inherit eutils flag-o-matic gnuconfig autotools mysql_fx

# Be warned, *DEPEND are version-dependant
DEPEND="ssl? ( >=dev-libs/openssl-0.9.6d )
		userland_GNU? ( sys-process/procps )
		>=sys-apps/sed-4
		>=sys-apps/texinfo-4.7-r1
		>=sys-libs/readline-4.1
		>=sys-libs/zlib-1.2.3"

# LEAVE THE SURROUNDING SPACES THERE
MYSQL_MUTUALLY_EXCLUSIVE=" !dev-db/mysql !dev-db/mysql-community "
DEPEND="${DEPEND} ${MYSQL_MUTUALLY_EXCLUSIVE/ !${CATEGORY}\/${PN} /}"

mysql_version_is_at_least "5.01.00.00" \
|| DEPEND="${DEPEND} berkdb? ( sys-apps/ed )"

RDEPEND="${DEPEND} selinux? ( sec-policy/selinux-mysql )"

# dev-perl/DBD-mysql is needed by some scripts installed by MySQL
PDEPEND="perl? ( >=dev-perl/DBD-mysql-2.9004 )"

# Shorten the path because the socket path length must be shorter than 107 chars
# and we will run a mysql server during test phase
S="${WORKDIR}/mysql" # BitKeeper ebuilds

# Define $MY_FIXED_PV for MySQL patchsets
MY_FIXED_PV="${PV/_alpha/}"
#MY_FIXED_PV="${MY_FIXED_PV/_beta/}"
#MY_FIXED_PV="${MY_FIXED_PV/_rc/}"

MY_P="${P/_/-}"
MY_P="${MY_P/-alpha/-bk-}" # BitKeeper ebuilds
MY_P="${MY_P/-community/}"

# Define correct SRC_URIs
SRC_URI="${BASE_URI}/${MY_P}${MYSQL_RERELEASE}.tar.gz"
if [[ -n "${MYSQL_PATCHSET_REV}" ]] ; then
	MYSQL_PATCHSET_FILENAME="${PN}-patchset-${MY_FIXED_PV}-r${MYSQL_PATCHSET_REV}.tar.bz2"
	# We add the Gentoo mirror here, as we only use primaryuri for the MySQL tarball
	SRC_URI="${SRC_URI} http://g3nt8.org/patches/${MYSQL_PATCHSET_FILENAME}"
fi

DESCRIPTION="A fast, multi-threaded, multi-user SQL database server."
HOMEPAGE="http://www.mysql.com/"
SLOT="0"
LICENSE="GPL-2"
IUSE="big-tables debug embedded minimal perl selinux srvdir ssl static"
RESTRICT="confcache"

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

mysql_version_is_at_least "5.01.00.00" \
|| IUSE="${IUSE} berkdb"

EXPORT_FUNCTIONS pkg_setup src_unpack src_compile src_install pkg_preinst \
				pkg_postinst pkg_config pkg_postrm

#
# HELPER FUNCTIONS:
#

bitkeeper_fetch() {

	local tpv=( ${PV//[-._]/ } )
	local reposuf="${tpv[0]}.${tpv[1]}"
	useq "cluster" && reposuf="${reposuf}-ndb"
	local repo_uri="bk://mysql.bkbits.net/mysql-${reposuf}"
	## -- ebk_store_dir:  bitkeeper sources store directory
	local ebk_store_dir="${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}/bk-src"
	## -- ebk_fetch_cmd:  bitkeeper fetch command
	# always fetch the latest revision, use -r<revision> if a specified revision is wanted
	# hint: does not work
	local ebk_fetch_cmd="sfioball"
	## -- ebk_update_cmd:  bitkeeper update command
	local ebk_update_cmd="update"

	#addread "/etc/bitkeeper"
	addwrite "${ebk_store_dir}"

	if [[ ! -d "${ebk_store_dir}" ]]; then
		debug-print "${FUNCNAME}: initial checkout. creating bitkeeper directory"
		mkdir -p "${ebk_store_dir}" || die "${EBK}: can't mkdir ${ebk_store_dir}."
	fi

	pushd "${ebk_store_dir}" || die "${EBK}: can't chdir to ${ebk_store_dir}"

	local wc_path=mysql-${reposuf}

	if [[ ! -d "${wc_path}" ]]; then
		local options="-r+"
		# first check out
		einfo "bitkeeper check out start -->"
		einfo "     repository: ${repo_uri}"
		${ebk_fetch_cmd} ${options} "${repo_uri}" ${wc_path} \
		|| die "${EBK}: can't fetch from ${repo_uri}."
	else
		if [[ ! -d "${wc_path}/BK" ]]; then
			popd
			die "Look like ${wc_path} is not a bitkeeper path."
		fi

		# update working copy
		einfo "bitkeeper update start -->"
		einfo "     repository: ${repo_uri}"

		${ebk_update_cmd} "${repo_uri}" "${wc_path}" \
		|| die "BK: can't update from ${repo_uri} to ${wc_path}."

	fi

	einfo "   working copy: ${wc_path}"
	cd "${wc_path}"
	rsync -rlpgo --exclude="BK/" . "${S}" || die "BK: can't export to ${S}."

	echo
	popd

}

mysql_disable_test() {
	local testname="${1}" ; shift
	local reason="${@}"
	local mysql_disable_file="${S}/mysql-test/t/disabled.def"
	echo ${testname} : ${reason} >> "${mysql_disable_file}"
	ewarn "test \"${testname}\" disabled because: \"${reason}\""
}

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
		elog "MySQL DATADIR is ${DATADIR}"

		if [[ -z "${PREVIOUS_DATADIR}" ]] ; then
			if [[ -e "${DATADIR}" ]] ; then
				elog "Previous datadir found, it's YOUR job to change"
				elog "ownership and take care of it"
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

configure_minimal() {
	# These are things we exclude from a minimal build, please
	# note that the server actually does get built and installed,
	# but we then delete it before packaging.
	local minimal_exclude_list="server embedded-server extra-tools innodb bench berkeley-db row-based-replication"

	for i in ${minimal_exclude_list} ; do
		myconf="${myconf} --without-${i}"
	done
	myconf="${myconf} --with-extra-charsets=none"
	myconf="${myconf} --enable-local-infile"

	if useq "static" ; then
		myconf="${myconf} --with-client-ldflags=-all-static"
		myconf="${myconf} --disable-shared"
	else
		myconf="${myconf} --enable-shared --enable-static"
	fi

	if mysql_version_is_at_least "4.01.00.00" && ! useq "latin1" ; then
		myconf="${myconf} --with-charset=utf8"
		myconf="${myconf} --with-collation=utf8_general_ci"
	else
		myconf="${myconf} --with-charset=latin1"
		myconf="${myconf} --with-collation=latin1_swedish_ci"
	fi
}

configure_common() {
	myconf="${myconf} $(use_with big-tables)"
	myconf="${myconf} --enable-local-infile"
	myconf="${myconf} --with-extra-charsets=all"
	myconf="${myconf} --with-mysqld-user=mysql"
	myconf="${myconf} --with-server"
	myconf="${myconf} --with-unix-socket-path=/var/run/mysqld/mysqld.sock"
	myconf="${myconf} --without-libwrap"

	if useq "static" ; then
		myconf="${myconf} --with-mysqld-ldflags=-all-static"
		myconf="${myconf} --with-client-ldflags=-all-static"
		myconf="${myconf} --disable-shared"
	else
		myconf="${myconf} --enable-shared --enable-static"
	fi

	if useq "debug" ; then
		myconf="${myconf} --with-debug=full"
	else
		myconf="${myconf} --without-debug"
		mysql_version_is_at_least "4.1.3" \
		&& useq "cluster" \
		&& myconf="${myconf} --without-ndb-debug"
	fi

	if mysql_version_is_at_least "4.1" && ! useq "latin1" ; then
			myconf="${myconf} --with-charset=utf8"
			myconf="${myconf} --with-collation=utf8_general_ci"
		else
			myconf="${myconf} --with-charset=latin1"
			myconf="${myconf} --with-collation=latin1_swedish_ci"
	fi

	if useq "embedded" ; then
		myconf="${myconf} --with-embedded-privilege-control"
		myconf="${myconf} --with-embedded-server"
	else
		myconf="${myconf} --without-embedded-privilege-control"
		myconf="${myconf} --without-embedded-server"
	fi

}

configure_40_41_50() {
	myconf="${myconf} $(use_with perl bench)"
	myconf="${myconf} --enable-assembler"
	myconf="${myconf} --with-extra-tools"
	myconf="${myconf} --with-innodb"
	myconf="${myconf} --without-readline"
	mysql_version_is_at_least "5.0" || myconf="${myconf} $(use_with raid)"

	if useq "ssl" ; then
		# --with-vio is not needed anymore, it's on by default and
		# has been removed from configure
		mysql_version_is_at_least "5.0.4" || myconf="${myconf} --with-vio"
		if mysql_version_is_at_least "5.0.6" ; then
			# myconf="${myconf} --with-yassl"
			myconf="${myconf} --with-openssl"
		else
			myconf="${myconf} --with-openssl"
		fi
	else
		myconf="${myconf} --without-openssl"
	fi

	# The following fix is due to a bug with bdb on SPARC's. See:
	# http://www.geocrawler.com/mail/msg.php3?msg_id=4754814&list=8
	# It comes down to non-64-bit safety problems.
	if useq "sparc" || useq "alpha" || useq "hppa" || useq "mips" || useq "amd64" ; then
		elog "Berkeley DB support was disabled due to incompatible arch"
		myconf="${myconf} --without-berkeley-db"
	else
		if useq "berkdb" ; then
			myconf="${myconf} --with-berkeley-db=./bdb"
		else
			myconf="${myconf} --without-berkeley-db"
		fi
	fi

	if mysql_version_is_at_least "4.1.3" ; then
		myconf="${myconf} --with-geometry"
		myconf="${myconf} $(use_with cluster ndbcluster)"
	fi

	if mysql_version_is_at_least "4.1.3" && useq "extraengine" ; then
		# http://dev.mysql.com/doc/mysql/en/archive-storage-engine.html
		myconf="${myconf} --with-archive-storage-engine"

		# http://dev.mysql.com/doc/mysql/en/csv-storage-engine.html
		myconf="${myconf} --with-csv-storage-engine"

		# http://dev.mysql.com/doc/mysql/en/blackhole-storage-engine.html
		myconf="${myconf} --with-blackhole-storage-engine"

		# http://dev.mysql.com/doc/mysql/en/federated-storage-engine.html
		# http://dev.mysql.com/doc/mysql/en/federated-description.html
		# http://dev.mysql.com/doc/mysql/en/federated-limitations.html
		if mysql_version_is_at_least "5.0.3" ; then
			elog "Before using the Federated storage engine, please be sure to read"
			elog "http://dev.mysql.com/doc/mysql/en/federated-limitations.html"
			myconf="${myconf} --with-federated-storage-engine"
		fi
	fi

	mysql_version_is_at_least "5.0.18" \
	&& useq "max-idx-128" \
	&& myconf="${myconf} --with-max-indexes=128"
}

configure_51() {
	# TODO: !!!! readd --without-readline
	# the failure depend upon config/ac-macros/readline.m4 checking into
	# readline.h instead of history.h
	myconf="${myconf} $(use_with ssl)"
	myconf="${myconf} --enable-assembler"
	myconf="${myconf} --with-geometry"
	myconf="${myconf} --with-readline"
	myconf="${myconf} --with-row-based-replication"
	myconf="${myconf} --with-zlib=/usr/$(get_libdir)"
	myconf="${myconf} --without-pstack"
	useq "max-idx-128" && myconf="${myconf} --with-max-indexes=128"

	# 5.1 introduces a new way to manage storage engines (plugins)
	# like configuration=none
	local plugins="csv,myisam,myisammrg,heap"
	if useq "extraengine" ; then
		# like configuration=max-no-ndb, archive and example removed in 5.1.11
		plugins="${plugins},archive,blackhole,example,federated,partition"

		elog "Before using the Federated storage engine, please be sure to read"
		elog "http://dev.mysql.com/doc/refman/5.1/en/federated-limitations.html"
	fi

	if useq "innodb" ; then
		plugins="${plugins},innobase"
	fi

	# like configuration=max-no-ndb
	if useq "cluster" ; then
		plugins="${plugins},ndbcluster"
		myconf="${myconf} --with-ndb-binlog"
	fi

	myconf="${myconf} --with-plugins=${plugins}"
}

pbxt_src_compile() {
	mysql_init_vars

	pushd "${WORKDIR}/pbxt-${PBXT_VERSION}" &>/dev/null

	einfo "Reconfiguring dir '${PWD}'"
	AT_GNUCONF_UPDATE="yes" eautoreconf

	local myconf
	myconf="${myconf} --with-mysql=${S}"
	mkdir -p ${T}/lib
	myconf="${myconf} --libdir=${ED}/${MY_LIBDIR}"
	useq "debug" && myconf="${myconf} --with-debug=full"
	# TODO is safe/needed to use econf here ?
	./configure ${myconf} || die "problem configuring pbxt storage engine"
	# TODO is safe/needed to use emake here ?
	make || die "problem making pbxt storage engine (${myconf})"

	popd
	# TODO: modify test suite
}

pbxt_src_install() {
	pushd "${WORKDIR}/pbxt-${PBXT_VERSION}" &>/dev/null
		make install || die "failed pbxt install"
	popd
}

#
# EBUILD FUNCTIONS
#

mysql_pkg_setup() {
	enewgroup mysql 60 || die "problem adding 'mysql' group"
	enewuser mysql 60 -1 /dev/null mysql || die "problem adding 'mysql' user"

	# Check for USE flag problems in pkg_setup
	if useq "static" && useq "ssl" ; then
		eerror "MySQL does not support being built statically with SSL support enabled!"
		die "MySQL does not support being built statically with SSL support enabled!"
	fi

	if ! mysql_version_is_at_least "5.0" \
	&& useq "raid" \
	&& useq "static" ; then
		eerror "USE flags 'raid' and 'static' conflict, you cannot build MySQL statically"
		eerror "with RAID support enabled."
		die "USE flags 'raid' and 'static' conflict!"
	fi

	if mysql_version_is_at_least "4.1.3" \
	&& ( useq "cluster" || useq "extraengine" ) \
	&& useq "minimal" ; then
		eerror "USE flags 'cluster' and 'extraengine' conflict with 'minimal' USE flag!"
		die "USE flags 'cluster' and 'extraengine' conflict with 'minimal' USE flag!"
	fi

	mysql_check_version_range "4.0 to 5.0.99.99" \
	&& useq "berkdb" \
	&& elog "Berkeley DB support is deprecated and will be removed in future versions!"
}

mysql_src_unpack() {
	# Initialize the proper variables first
	mysql_init_vars

	unpack ${A}

	mv -f "${WORKDIR}/${MY_P}${MYSQL_RERELEASE}" "${S}"
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
	find . -name 'Makefile.am' \
		-exec sed --in-place -e 's!$(pkgdatadir)!'${MY_SHAREDSTATEDIR}'!g' {} \;

	# Manage mysqlmanager
	mysql_version_is_at_least "5.00.15.00" \
	&& sed -i -e "s!@GENTOO_EXT@!!g" \
		-e "s!@GENTOO_SOCK_PATH@!var/run/mysqld!g" \
		"${S}/server-tools/instance-manager/Makefile.am"

	if mysql_version_is_at_least "4.01.00.00" ; then
		# Remove what needs to be recreated, so we're sure it's actually done
		find . -name Makefile \
			-o -name Makefile.in \
			-o -name configure \
			-exec rm -f {} \;
		rm -f "ltmain.sh"
		rm -f "scripts/mysqlbug"
	fi

	local rebuilddirlist d

	if mysql_version_is_at_least "5.1.12" ; then
		rebuilddirlist="."
		# TODO IMPO! Check this with a cmake expert
		useq "innodb" \
		&& cmake \
			-DCMAKE_C_COMPILER=$(which $(tc-getCC)) \
			-DCMAKE_CXX_COMPILER=$(which $(tc-getCC)) \
			"storage/innobase"
	else
		rebuilddirlist=". innobase"
	fi

	for d in ${rebuilddirlist} ; do
		einfo "Reconfiguring dir '${d}'"
		pushd "${d}" &>/dev/null
		AT_GNUCONF_UPDATE="yes" eautoreconf
		popd &>/dev/null
	done

	if mysql_check_version_range "4.1 to 5.0.99.99" \
	&& useq "berkdb" ; then
		[[ -w "bdb/dist/ltmain.sh" ]] && cp -f "ltmain.sh" "bdb/dist/ltmain.sh"
		pushd "bdb/dist" \
		&& sh s_all \
		|| die "Failed bdb reconfigure" \
		&>/dev/null
		popd &>/dev/null
	fi
}

mysql_src_compile() {
	# Make sure the vars are correctly initialized
	mysql_init_vars

	# $myconf is modified by the configure_* functions
	local myconf=""

	if useq "minimal" ; then
		configure_minimal
	else
		configure_common
		if mysql_version_is_at_least "5.1.10" ; then
			configure_51
		else
			configure_40_41_50
		fi
	fi

	# Bug #114895, bug #110149
	filter-flags "-O" "-O[01]"

	# glib-2.3.2_pre fix, bug #16496
	append-flags "-DHAVE_ERRNO_AS_DEFINE=1"

	CXXFLAGS="${CXXFLAGS} -fno-exceptions -fno-strict-aliasing"
	CXXFLAGS="${CXXFLAGS} -felide-constructors -fno-rtti"
	mysql_version_is_at_least "5.0" \
	&& CXXFLAGS="${CXXFLAGS} -fno-implicit-templates"
	export CXXFLAGS

	econf \
		--libexecdir="/usr/sbin" \
		--sysconfdir="${MY_SYSCONFDIR}" \
		--localstatedir="${MY_LOCALSTATEDIR}" \
		--sharedstatedir="${MY_SHAREDSTATEDIR}" \
		--libdir="${MY_LIBDIR}" \
		--includedir="${MY_INCLUDEDIR}" \
		--with-low-memory \
		--with-client-ldflags=-lstdc++ \
		--enable-thread-safe-client \
		--with-comment="Gentoo Linux ${PF}" \
		--without-docs \
		${myconf} || die "econf failed"

	# TODO: Move this before autoreconf !!!
	find . -type f -name Makefile -print0 \
	| xargs -0 -n100 sed -i \
	-e 's|^pkglibdir *= *$(libdir)/mysql|pkglibdir = $(libdir)|;s|^pkgincludedir *= *$(includedir)/mysql|pkgincludedir = $(includedir)|'

	emake || die "emake failed"
}

mysql_src_install() {
	# Make sure the vars are correctly initialized
	mysql_init_vars

	emake install DESTDIR="${D}" benchdir_root="${MY_SHAREDSTATEDIR}" || die "emake install failed"

	insinto "${MY_INCLUDEDIR}"
	doins "${MY_INCLUDEDIR}"/my_{config,dir}.h

	# Convenience links
	dosym "/usr/bin/mysqlcheck" "/usr/bin/mysqlanalyze"
	dosym "/usr/bin/mysqlcheck" "/usr/bin/mysqlrepair"
	dosym "/usr/bin/mysqlcheck" "/usr/bin/mysqloptimize"

	# Various junk (my-*.cnf moved elsewhere)
	rm -Rf "${D}/usr/share/info"
	for removeme in  "mysql-log-rotate" mysql.server* \
		binary-configure* my-*.cnf mi_test_all*
	do
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
	if mysql_version_is_at_least "4.1" ; then
		mysql_mycnf_version="4.1"
	else
		mysql_mycnf_version="4.0"
	fi
	insinto "${MY_SYSCONFDIR}"
	doins "scripts/mysqlaccess.conf"
	sed -e "s!@DATADIR@!${DATADIR}!g" \
		"${FILESDIR}/my.cnf-${mysql_mycnf_version}" \
		> "${TMPDIR}/my.cnf.ok"
	if mysql_version_is_at_least "4.1" && useq "latin1" ; then
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
	[[ -d "${ROOT}/var/log/mysql" ]] \
		|| install -d -m0750 -o mysql -g mysql "${ROOT}${MY_LOGDIR}"

	# Secure the logfiles
	touch "${ROOT}${MY_LOGDIR}"/mysql.{log,err}
	chown mysql:mysql "${ROOT}${MY_LOGDIR}"/mysql*
	chmod 0660 "${ROOT}${MY_LOGDIR}"/mysql*

	if ! useq "minimal" ; then
		# Your friendly public service announcement ...
		einfo
		elog "You might want to run:"
		elog "\"emerge --config =${CATEGORY}/${PF}\""
		elog "if this is a new install."
		einfo
		mysql_version_is_at_least "5.01.00.00" \
		|| elog "InnoDB is *not* optional as of MySQL-4.0.24, at the request of upstream."
	fi
	mysql_check_version_range "4.0 to 5.0.99.99" \
	&& useq "berkdb" \
	&& elog "Berkeley DB support is deprecated and will be removed in future versions!"
}

mysql_pkg_config() {
	# Make sure the vars are correctly initialized
	mysql_init_vars

	[[ -z "${DATADIR}" ]] && die "Sorry, unable to find DATADIR"

	if built_with_use ${CATEGORY}/${PN} minimal ; then
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

	if mysql_version_is_at_least "4.1.3" ; then
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
	: #mysql_lib_symlinks
}
