# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mysql.eclass,v 1.75 2007/04/25 18:22:37 robbat2 Exp $

# Author: Francesco Riosa (Retired) <vivo@gentoo.org>
# Maintainer: Luca Longinotti <chtekk@gentoo.org>

# Both MYSQL_VERSION_ID and MYSQL_PATCHSET_REV must be set in the ebuild too!
# Note that MYSQL_VERSION_ID must be empty!

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit eutils flag-o-matic gnuconfig autotools mysql_fx

# Shorten the path because the socket path length must be shorter than 107 chars
# and we will run a mysql server during test phase
S="${WORKDIR}/mysql"

[[ "${MY_EXTRAS_VER}" == "latest" ]] && MY_EXTRAS_VER="20070108"

if [[ ${PR#r} -lt 60 ]] ; then
	IS_BITKEEPER=0
elif [[ ${PR#r} -lt 90 ]] ; then
	IS_BITKEEPER=60
else
	IS_BITKEEPER=90
fi

# MYSQL_VERSION_ID will be:
# major * 10e6 + minor * 10e4 + micro * 10e2 + gentoo revision number, all [0..99]
# This is an important part, because many of the choices the MySQL ebuild will do
# depend on this variable.
# In particular, the code below transforms a $PVR like "5.0.18-r3" in "5001803"

MYSQL_VERSION_ID=""
tpv=( ${PV//[-._]/ } ) ; tpv[3]="${PVR:${#PV}}" ; tpv[3]="${tpv[3]##*-r}"
for vatom in 0 1 2 3 ; do
	# pad to length 2
	tpv[${vatom}]="00${tpv[${vatom}]}"
	MYSQL_VERSION_ID="${MYSQL_VERSION_ID}${tpv[${vatom}]:0-2}"
done
# strip leading "0" (otherwise it's considered an octal number by BASH)
MYSQL_VERSION_ID=${MYSQL_VERSION_ID##"0"}

# Be warned, *DEPEND are version-dependant
DEPEND="ssl? ( >=dev-libs/openssl-0.9.6d )
		userland_GNU? ( sys-process/procps )
		>=sys-apps/sed-4
		>=sys-apps/texinfo-4.7-r1
		>=sys-libs/readline-4.1
		>=sys-libs/zlib-1.2.3"

# Having different flavours at the same time is not a good idea
for i in "" "-community" ; do
	[[ "${i}" == ${PN#mysql} ]] ||
	DEPEND="${DEPEND} !dev-db/mysql${i}"
done

mysql_version_is_at_least "5.1" \
|| DEPEND="${DEPEND} berkdb? ( sys-apps/ed )"

mysql_version_is_at_least "5.1.12" \
&& DEPEND="${DEPEND} innodb? ( >=dev-util/cmake-2.4.3 )"

# dev-perl/DBD-mysql is needed by some scripts installed by MySQL
PDEPEND="perl? ( >=dev-perl/DBD-mysql-2.9004 )"

# BitKeeper dependency, compile-time only
[[ ${IS_BITKEEPER} -eq 90 ]] && DEPEND="${DEPEND} dev-util/bk_client"

# Define correct SRC_URIs
SRC_URI="${SERVER_URI}
		mirror://gentoo/mysql-extras-${MY_EXTRAS_VER}.tar.bz2
		http://g3nt8.org/patches/mysql-extras-${MY_EXTRAS_VER}.tar.bz2"
mysql_version_is_at_least "5.1.12" \
&& [[ -n "${PBXT_VERSION}" ]] \
&& SRC_URI="${SRC_URI} pbxt? ( mirror://sourceforge/pbxt/pbxt-${PBXT_VERSION}.tar.gz )"

DESCRIPTION="A fast, multi-threaded, multi-user SQL database server."
HOMEPAGE="http://www.mysql.com/"
LICENSE="GPL-2"
SLOT="0"
IUSE="big-tables debug embedded minimal perl selinux ssl static"
RESTRICT="confcache"

mysql_version_is_at_least "4.1" \
&& IUSE="${IUSE} latin1"

mysql_version_is_at_least "4.1.3" \
&& IUSE="${IUSE} cluster extraengine"

mysql_version_is_at_least "5.0" \
|| IUSE="${IUSE} raid"

mysql_version_is_at_least "5.0.18" \
&& IUSE="${IUSE} max-idx-128"

mysql_version_is_at_least "5.1" \
&& IUSE="${IUSE} innodb"

mysql_version_is_at_least "5.1" \
|| IUSE="${IUSE} berkdb"

mysql_version_is_at_least "5.1.12" \
&& IUSE="${IUSE} pbxt"

RDEPEND="${DEPEND}
		!minimal? ( dev-db/mysql-init-scripts )
		selinux? ( sec-policy/selinux-mysql )"

EXPORT_FUNCTIONS pkg_setup src_unpack src_compile src_install pkg_preinst \
				pkg_postinst pkg_config pkg_postrm

#
# HELPER FUNCTIONS:
#

bitkeeper_fetch() {
	local reposuf
	if [[ -z "${1}" ]] ; then
		local tpv
		tpv=( ${PV//[-._]/ } )
		reposuf="mysql-${tpv[0]}.${tpv[1]}"
	else
		reposuf="${1}"
	fi
	einfo "Using '${reposuf}' repository."
	local repo_uri="bk://mysql.bkbits.net/${reposuf}"
	## -- ebk_store_dir: bitkeeper sources store directory
	local ebk_store_dir="${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}/bk-src"
	## -- ebk_fetch_cmd: bitkeeper fetch command
	# always fetch the latest revision, use -r<revision> if a specified revision is wanted
	# hint: does not work
	local ebk_fetch_cmd="sfioball"
	## -- ebk_update_cmd: bitkeeper update command
	local ebk_update_cmd="update"

	# addread "/etc/bitkeeper"
	addwrite "${ebk_store_dir}"

	if [[ ! -d "${ebk_store_dir}" ]] ; then
		debug-print "${FUNCNAME}: initial checkout, creating bitkeeper directory ..."
		mkdir -p "${ebk_store_dir}" || die "BK: couldn't mkdir ${ebk_store_dir}"
	fi

	pushd "${ebk_store_dir}" || die "BK: couldn't chdir to ${ebk_store_dir}"

	local wc_path=${reposuf}

	if [[ ! -d "${wc_path}" ]] ; then
		local options="-r+"

		# first checkout
		einfo "bitkeeper checkout start -->"
		einfo "    repository: ${repo_uri}"

		${ebk_fetch_cmd} ${options} "${repo_uri}" "${wc_path}" \
		|| die "BK: couldn't fetch from ${repo_uri}"
	else
		if [[ ! -d "${wc_path}/BK" ]] ; then
			popd
			die "Looks like ${wc_path} is not a bitkeeper path"
		fi

		# update working copy
		einfo "bitkeeper update start -->"
		einfo "    repository: ${repo_uri}"

		${ebk_update_cmd} "${repo_uri}" "${wc_path}" \
		|| die "BK: couldn't update from ${repo_uri} to ${wc_path}"
	fi

	einfo "  working copy: ${wc_path}"
	cd "${wc_path}"
	rsync -rlpgo --exclude="BK/" . "${S}" || die "BK: couldn't export to ${S}"

	echo
	popd
}

mysql_disable_test() {
	local testname="${1}" ; shift
	local reason="${@}"
	local mysql_disable_file="${S}/mysql-test/t/disabled.def"
	echo ${testname} : ${reason} >> "${mysql_disable_file}"
	ewarn "test '${testname}' disabled: '${reason}'"
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

	if [[ -z "${MY_DATADIR}" ]] ; then
		MY_DATADIR=""
		if [[ -f "${MY_SYSCONFDIR}/my.cnf" ]] ; then
			MY_DATADIR=`"my_print_defaults" mysqld 2>/dev/null \
				| sed -ne '/datadir/s|^--datadir=||p' \
				| tail -n1`
			if [[ -z "${MY_DATADIR}" ]] ; then
				MY_DATADIR=`grep ^datadir "${MY_SYSCONFDIR}/my.cnf" \
				| sed -e 's/.*=\s*//'`
			fi
		fi
		if [[ -z "${MY_DATADIR}" ]] ; then
			MY_DATADIR="${MY_LOCALSTATEDIR}"
			einfo "Using default MY_DATADIR"
		fi
		elog "MySQL MY_DATADIR is ${MY_DATADIR}"

		if [[ -z "${PREVIOUS_DATADIR}" ]] ; then
			if [[ -e "${MY_DATADIR}" ]] ; then
				elog "Previous datadir found, it's YOUR job to change"
				elog "ownership and take care of it"
				PREVIOUS_DATADIR="yes"
			else
				PREVIOUS_DATADIR="no"
			fi
			export PREVIOUS_DATADIR
		fi
	fi

	MY_SOURCEDIR=${SERVER_URI##*/}
	MY_SOURCEDIR=${MY_SOURCEDIR%.tar*}

	export MY_SHAREDSTATEDIR MY_SYSCONFDIR
	export MY_LIBDIR MY_LOCALSTATEDIR MY_LOGDIR
	export MY_INCLUDEDIR MY_DATADIR MY_SOURCEDIR
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

	if use static ; then
		myconf="${myconf} --with-client-ldflags=-all-static"
		myconf="${myconf} --disable-shared"
	else
		myconf="${myconf} --enable-shared --enable-static"
	fi

	if mysql_version_is_at_least "4.1" && ! use latin1 ; then
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

	if use static ; then
		myconf="${myconf} --with-mysqld-ldflags=-all-static"
		myconf="${myconf} --with-client-ldflags=-all-static"
		myconf="${myconf} --disable-shared"
	else
		myconf="${myconf} --enable-shared --enable-static"
	fi

	if use debug ; then
		myconf="${myconf} --with-debug=full"
	else
		myconf="${myconf} --without-debug"
		mysql_version_is_at_least "4.1.3" \
		&& use cluster \
		&& myconf="${myconf} --without-ndb-debug"
	fi

	if mysql_version_is_at_least "4.1" && ! use latin1 ; then
			myconf="${myconf} --with-charset=utf8"
			myconf="${myconf} --with-collation=utf8_general_ci"
		else
			myconf="${myconf} --with-charset=latin1"
			myconf="${myconf} --with-collation=latin1_swedish_ci"
	fi

	if use embedded ; then
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

	# --with-vio is not needed anymore, it's on by default and
	# has been removed from configure
	if use ssl ; then
		 mysql_version_is_at_least "5.0.4" || myconf="${myconf} --with-vio"
	fi

	if mysql_version_is_at_least "5.1.11" ; then
		myconf="${myconf} $(use_with ssl)"
	else
		myconf="${myconf} $(use_with ssl openssl)"
	fi

	# The following fix is due to a bug with bdb on SPARC's. See:
	# http://www.geocrawler.com/mail/msg.php3?msg_id=4754814&list=8
	# It comes down to non-64-bit safety problems.
	if use alpha || use amd64 || use hppa || use mips || use sparc ; then
		elog "Berkeley DB support was disabled due to incompatible arch"
		myconf="${myconf} --without-berkeley-db"
	else
		if use berkdb ; then
			myconf="${myconf} --with-berkeley-db=./bdb"
		else
			myconf="${myconf} --without-berkeley-db"
		fi
	fi

	if mysql_version_is_at_least "4.1.3" ; then
		myconf="${myconf} --with-geometry"
		myconf="${myconf} $(use_with cluster ndbcluster)"
	fi

	if mysql_version_is_at_least "4.1.3" && use extraengine ; then
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
	&& use max-idx-128 \
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
	use max-idx-128 && myconf="${myconf} --with-max-indexes=128"

	# 5.1 introduces a new way to manage storage engines (plugins)
	# like configuration=none
	local plugins="csv,myisam,myisammrg,heap"
	if use extraengine ; then
		# like configuration=max-no-ndb, archive and example removed in 5.1.11
		plugins="${plugins},archive,blackhole,example,federated,partition"

		elog "Before using the Federated storage engine, please be sure to read"
		elog "http://dev.mysql.com/doc/refman/5.1/en/federated-limitations.html"
	fi

	if use innodb ; then
		plugins="${plugins},innobase"
	fi

	# like configuration=max-no-ndb
	if use cluster ; then
		plugins="${plugins},ndbcluster"
		myconf="${myconf} --with-ndb-binlog"
	fi

	if mysql_version_is_at_least "5.2" ; then
		plugins="${plugins},falcon"
	fi

	myconf="${myconf} --with-plugins=${plugins}"
}

pbxt_src_compile() {
	mysql_init_vars

	pushd "${WORKDIR}/pbxt-${PBXT_VERSION}" &>/dev/null

	einfo "Reconfiguring dir '${PWD}'"
	AT_GNUCONF_UPDATE="yes" eautoreconf

	local myconf=""
	myconf="${myconf} --with-mysql=${S} --libdir=${ED}/${MY_LIBDIR}"
	use debug && myconf="${myconf} --with-debug=full"
	# TODO: is it safe/needed to use econf here ?
	./configure ${myconf} || die "Problem configuring PBXT storage engine"
	# TODO: is it safe/needed to use emake here ?
	make || die "Problem making PBXT storage engine (${myconf})"

	popd
	# TODO: modify test suite for PBXT
}

pbxt_src_install() {
	pushd "${WORKDIR}/pbxt-${PBXT_VERSION}" &>/dev/null
		make install || die "Failed to install PBXT"
	popd
}

#
# EBUILD FUNCTIONS
#

mysql_pkg_setup() {
	enewgroup mysql 60 || die "problem adding 'mysql' group"
	enewuser mysql 60 -1 /dev/null mysql || die "problem adding 'mysql' user"

	# Check for USE flag problems in pkg_setup
	if use static && use ssl ; then
		eerror "MySQL does not support being built statically with SSL support enabled!"
		die "MySQL does not support being built statically with SSL support enabled!"
	fi

	if ! mysql_version_is_at_least "5.0" \
	&& use raid \
	&& use static ; then
		eerror "USE flags 'raid' and 'static' conflict, you cannot build MySQL statically"
		eerror "with RAID support enabled."
		die "USE flags 'raid' and 'static' conflict!"
	fi

	if mysql_version_is_at_least "4.1.3" \
	&& ( use cluster || use extraengine ) \
	&& use minimal ; then
		eerror "USE flags 'cluster' and 'extraengine' conflict with 'minimal' USE flag!"
		die "USE flags 'cluster' and 'extraengine' conflict with 'minimal' USE flag!"
	fi

	mysql_check_version_range "4.0 to 5.0.99.99" \
	&& use berkdb \
	&& elog "Berkeley DB support is deprecated and will be removed in future versions!"
}

mysql_src_unpack() {
	# Initialize the proper variables first
	mysql_init_vars

	unpack ${A}
	if [[ ${IS_BITKEEPER} -eq 90 ]] ; then
		if mysql_check_version_range "5.1 to 5.1.99" ; then
			bitkeeper_fetch "mysql-5.1-ndb"
		elif mysql_check_version_range "5.2 to 5.2.99" ; then
			bitkeeper_fetch "mysql-5.2-falcon"
		else
			bitkeeper_fetch
		fi
		cd "${S}"
		einfo "Running upstream autorun over BK sources ..."
		BUILD/autorun.sh
	else
		mv -f "${WORKDIR}/${MY_SOURCEDIR}" "${S}"
		cd "${S}"
	fi

	# Apply the patches for this MySQL version
	EPATCH_SUFFIX="patch"
	mkdir -p "${EPATCH_SOURCE}" || die "Unable to create epatch directory"
	mysql_mv_patches
	epatch

	# Additional checks, remove bundled zlib
	rm -f "${S}/zlib/"*.[ch]
	sed -i -e "s/zlib\/Makefile dnl/dnl zlib\/Makefile/" "${S}/configure.in"
	rm -f "scripts/mysqlbug"

	# Make charsets install in the right place
	find . -name 'Makefile.am' \
		-exec sed --in-place -e 's!$(pkgdatadir)!'${MY_SHAREDSTATEDIR}'!g' {} \;

	if mysql_version_is_at_least "4.1" ; then
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
		# TODO: check this with a cmake expert
		use innodb \
		&& cmake \
			-DCMAKE_C_COMPILER=$(type -P $(tc-getCC)) \
			-DCMAKE_CXX_COMPILER=$(type -P $(tc-getCC)) \
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
	&& use berkdb ; then
		[[ -w "bdb/dist/ltmain.sh" ]] && cp -f "ltmain.sh" "bdb/dist/ltmain.sh"
		cp -f "/usr/share/aclocal/libtool.m4" "bdb/dist/aclocal/libtool.ac" \
		|| die "Could not copy libtool.m4 to bdb/dist/"
		pushd "bdb/dist" &>/dev/null
		sh s_all \
		|| die "Failed bdb reconfigure"
		popd &>/dev/null
	fi
}

mysql_src_compile() {
	# Make sure the vars are correctly initialized
	mysql_init_vars

	# $myconf is modified by the configure_* functions
	local myconf=""

	if use minimal ; then
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

	mysql_version_is_at_least "5.1.12" && use pbxt && pbxt_src_compile
}

mysql_src_install() {
	# Make sure the vars are correctly initialized
	mysql_init_vars

	emake install DESTDIR="${D}" benchdir_root="${MY_SHAREDSTATEDIR}" || die "emake install failed"

	mysql_version_is_at_least "5.1.12" && use pbxt && pbxt_src_install

	insinto "${MY_INCLUDEDIR}"
	doins "${MY_INCLUDEDIR}"/my_{config,dir}.h

	# Convenience links
	dosym "/usr/bin/mysqlcheck" "/usr/bin/mysqlanalyze"
	dosym "/usr/bin/mysqlcheck" "/usr/bin/mysqlrepair"
	dosym "/usr/bin/mysqlcheck" "/usr/bin/mysqloptimize"

	# Various junk (my-*.cnf moved elsewhere)
	rm -Rf "${ED}/usr/share/info"
	for removeme in  "mysql-log-rotate" mysql.server* \
		binary-configure* my-*.cnf mi_test_all*
	do
		rm -f "${ED}"/usr/share/mysql/${removeme}
	done

	# Clean up stuff for a minimal build
	if use minimal ; then
		rm -Rf "${ED}${MY_SHAREDSTATEDIR}"/{mysql-test,sql-bench}
		rm -f "${ED}"/usr/bin/{mysql{_install_db,manager*,_secure_installation,_fix_privilege_tables,hotcopy,_convert_table_format,d_multi,_fix_extensions,_zap,_explain_log,_tableinfo,d_safe,_install,_waitpid,binlog,test},myisam*,isam*,pack_isam}
		rm -f "${ED}/usr/sbin/mysqld"
		rm -f "${ED}${MY_LIBDIR}"/lib{heap,merge,nisam,my{sys,strings,sqld,isammrg,isam},vio,dbug}.a
	fi

	# Configuration stuff
	if mysql_version_is_at_least "4.1" ; then
		mysql_mycnf_version="4.1"
	else
		mysql_mycnf_version="4.0"
	fi
	insinto "${MY_SYSCONFDIR}"
	doins scripts/mysqlaccess.conf
	sed -e "s!@DATADIR@!${MY_DATADIR}!g" \
		"${FILESDIR}/my.cnf-${mysql_mycnf_version}" \
		> "${TMPDIR}/my.cnf.ok"
	if mysql_version_is_at_least "4.1" && use latin1 ; then
		sed -e "s|utf8|latin1|g" -i "${TMPDIR}/my.cnf.ok"
	fi
	newins "${TMPDIR}/my.cnf.ok" my.cnf

	# Minimal builds don't have the MySQL server
	if ! use minimal ; then
		# Empty directories ...
		diropts "-m0750"
		if [[ "${PREVIOUS_DATADIR}" != "yes" ]] ; then
			dodir "${MY_DATADIR}"
			keepdir "${MY_DATADIR}"
			chown -R mysql:mysql "${ED}/${MY_DATADIR}"
		fi

		diropts "-m0755"
		for folder in "${MY_LOGDIR}" "/var/run/mysqld" ; do
			dodir "${folder}"
			keepdir "${folder}"
			chown -R mysql:mysql "${ED}/${folder}"
		done
	fi

	# Docs
	dodoc README COPYING ChangeLog EXCEPTIONS-CLIENT INSTALL-SOURCE

	# Minimal builds don't have the MySQL server
	if ! use minimal ; then
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

	mysql_lib_symlinks "${ED}"
}

mysql_pkg_preinst() {
	enewgroup mysql 60 || die "problem adding 'mysql' group"
	enewuser mysql 60 -1 /dev/null mysql || die "problem adding 'mysql' user"
}

mysql_pkg_postinst() {
	# Make sure the vars are correctly initialized
	mysql_init_vars

	# Check FEATURES="collision-protect" before removing this
	[[ -d "${EROOT}/var/log/mysql" ]] || install -d -m0750 -o mysql -g mysql "${EROOT}${MY_LOGDIR}"

	# Secure the logfiles
	touch "${EROOT}${MY_LOGDIR}"/mysql.{log,err}
	chown mysql:mysql "${EROOT}${MY_LOGDIR}"/mysql*
	chmod 0660 "${EROOT}${MY_LOGDIR}"/mysql*

	# Minimal builds don't have the MySQL server
	if ! use minimal ; then
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

		einfo
		elog "You might want to run:"
		elog "\"emerge --config =${CATEGORY}/${PF}\""
		elog "if this is a new install."
		einfo
	fi

	if mysql_version_is_at_least "5.1.12" && use pbxt ; then
		# TODO: explain it better
		elog "    mysql> INSTALL PLUGIN pbxt SONAME 'libpbxt.so';"
		elog "    mysql> CREATE TABLE t1 (c1 int, c2 text) ENGINE=pbxt;"
		elog "if, after that, you cannot start the MySQL server,"
		elog "remove the ${MY_DATADIR}/mysql/plugin.* files, then"
		elog "use the MySQL upgrade script to restore the table"
		elog "or execute the following SQL command:"
		elog "    CREATE TABLE IF NOT EXISTS plugin ("
		elog "      name char(64) binary DEFAULT '' NOT NULL,"
		elog "      dl char(128) DEFAULT '' NOT NULL,"
		elog "      PRIMARY KEY (name)"
		elog "    ) CHARACTER SET utf8 COLLATE utf8_bin;"
	fi

	mysql_check_version_range "4.0 to 5.0.99.99" \
	&& use berkdb \
	&& elog "Berkeley DB support is deprecated and will be removed in future versions!"
}

mysql_pkg_config() {
	# Make sure the vars are correctly initialized
	mysql_init_vars

	[[ -z "${MY_DATADIR}" ]] && die "Sorry, unable to find MY_DATADIR"

	if built_with_use ${CATEGORY}/${PN} minimal ; then
		die "Minimal builds do NOT include the MySQL server"
	fi

	local pwd1="a"
	local pwd2="b"
	local maxtry=5

	if [[ -d "${EROOT}/${MY_DATADIR}/mysql" ]] ; then
		ewarn "You have already a MySQL database in place."
		ewarn "(${EROOT}/${MY_DATADIR}/*)"
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

	local help_tables="${EROOT}${MY_SHAREDSTATEDIR}/fill_help_tables.sql"
	[[ -r "${help_tables}" ]] \
	&& cp "${help_tables}" "${TMPDIR}/fill_help_tables.sql" \
	|| touch "${TMPDIR}/fill_help_tables.sql"
	help_tables="${TMPDIR}/fill_help_tables.sql"

	pushd "${TMPDIR}" &>/dev/null
	"${EROOT}/usr/bin/mysql_install_db" | grep -B5 -A999 -i "ERROR"
	popd &>/dev/null
	[[ -f "${EROOT}/${MY_DATADIR}/mysql/user.frm" ]] \
	|| die "MySQL databases not installed"
	chown -R mysql:mysql "${EROOT}/${MY_DATADIR}" 2> /dev/null
	chmod 0750 "${EROOT}/${MY_DATADIR}" 2> /dev/null

	if mysql_version_is_at_least "4.1.3" ; then
		options="--skip-ndbcluster"

		# Filling timezones, see
		# http://dev.mysql.com/doc/mysql/en/time-zone-support.html
		"${EROOT}/usr/bin/mysql_tzinfo_to_sql" "${EROOT}/usr/share/zoneinfo" > "${sqltmp}" 2>/dev/null

		if [[ -r "${help_tables}" ]] ; then
			cat "${help_tables}" >> "${sqltmp}"
		fi
	fi

	local socket="${EROOT}/var/run/mysqld/mysqld${RANDOM}.sock"
	local pidfile="${EROOT}/var/run/mysqld/mysqld${RANDOM}.pid"
	local mysqld="${EROOT}/usr/sbin/mysqld \
		${options} \
		--user=mysql \
		--skip-grant-tables \
		--basedir=${EROOT}/usr \
		--datadir=${EROOT}/${MY_DATADIR} \
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
	"${EROOT}/usr/bin/mysql" \
		--socket=${socket} \
		-hlocalhost \
		-e "${sql}"

	einfo "Loading \"zoneinfo\", this step may require a few seconds ..."

	"${EROOT}/usr/bin/mysql" \
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
	: # mysql_lib_symlinks "${ED}"
}
