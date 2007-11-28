# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/apache-2.eclass,v 1.1 2007/11/28 13:04:12 hollow Exp $

# @ECLASS: apache-2
# @MAINTAINER: apache-devs@gentoo.org
# @BLURB: Provides a common set of functions for >=apache-2.2* ebuilds
# @DESCRIPTION:
# This eclass handles common apache ebuild functions in a sane way and providing
# information about where certain interfaces are located such as LoadModule
# generation and inter-module dependency checking.

inherit depend.apache eutils flag-o-matic multilib autotools

# ==============================================================================
# INTERNAL VARIABLES
# ==============================================================================

# @ECLASS-VARIABLE: GENTOO_PATCHNAME
# @DESCRIPTION:
# This internal variable contains the prefix for the patch tarball
GENTOO_PATCHNAME="gentoo-${PF}"

# @ECLASS-VARIABLE: GENTOO_PATCHDIR
# @DESCRIPTION:
# This internal variable contains the working directory where patches and config
# files are located
GENTOO_PATCHDIR="${WORKDIR}/${GENTOO_PATCHNAME}"

# @ECLASS-VARIABLE: GENTOO_DEVELOPER
# @DESCRIPTION:
# This variable needs to be set in the ebuild and contains the name of the
# gentoo developer who created the patch tarball

# @ECLASS-VARIABLE: GENTOO_PATCHSTAMP
# @DESCRIPTION:
# This variable needs to be set in the ebuild and contains the date the patch
# tarball was created at in YYMMDD format

SRC_URI="mirror://apache/httpd/httpd-${PV}.tar.bz2
	http://dev.gentoo.org/~${GENTOO_DEVELOPER}/dist/apache/${GENTOO_PATCHNAME}-${GENTOO_PATCHSTAMP}.tar.bz2"

# @ECLASS-VARIABLE: IUSE_MPMS_FORK
# @DESCRIPTION:
# This variable needs to be set in the ebuild and contains a list of forking
# (i.e.  non-threaded) MPMS

# @ECLASS-VARIABLE: IUSE_MPMS_THREAD
# @DESCRIPTION:
# This variable needs to be set in the ebuild and contains a list of threaded
# MPMS

# @ECLASS-VARIABLE: IUSE_MODULES
# @DESCRIPTION:
# This variable needs to be set in the ebuild and contains a list of available
# built-in modules

IUSE_MPMS="${IUSE_MPMS_FORK} ${IUSE_MPMS_THREAD}"
IUSE="debug doc ldap selinux ssl static suexec threads"

for module in ${IUSE_MODULES} ; do
	IUSE="${IUSE} apache2_modules_${module}"
done

for mpm in ${IUSE_MPMS} ; do
	IUSE="${IUSE} apache2_mpms_${mpm}"
done

DEPEND="dev-lang/perl
	=dev-libs/apr-1*
	=dev-libs/apr-util-1*
	dev-libs/libpcre
	ldap? ( =net-nds/openldap-2* )
	selinux? ( sec-policy/selinux-apache )
	ssl? ( dev-libs/openssl )
	!=www-servers/apache-1*"
RDEPEND="${DEPEND}"
PDEPEND="~app-admin/apache-tools-${PV}"

S="${WORKDIR}/httpd-${PV}"

# ==============================================================================
# INTERNAL FUNCTIONS
# ==============================================================================

# @ECLASS-VARIABLE: MY_MPM
# DESCRIPTION:
# This internal variable contains the selected MPM after a call to setup_mpm()

# @FUNCTION: setup_mpm
# @DESCRIPTION:
# This internal function makes sure that only one of APACHE2_MPMS was selected
# or a default based on USE=threads is selected if APACHE2_MPMS is empty
setup_mpm() {
	for x in ${IUSE_MPMS} ; do
		if use apache2_mpms_${x} ; then
			if [[ -z "${MY_MPM}" ]] ; then
				MY_MPM=${x}
				elog
				elog "Selected MPM: ${MY_MPM}"
				elog
			else
				eerror "You have selected more then one mpm USE-flag."
				eerror "Only one MPM is supported."
				die "more then one mpm was specified"
			fi
		fi
	done

	if [[ -z "${MY_MPM}" ]] ; then
		if use threads ; then
			MY_MPM=worker
			elog
			elog "Selected default threaded MPM: ${MY_MPM}"
			elog
		else
			MY_MPM=prefork
			elog
			elog "Selected default MPM: ${MY_MPM}"
			elog
		fi
	fi

	if has ${MY_MPM} ${IUSE_MPMS_THREAD} && ! use threads ; then
		eerror "You have selected a threaded MPM but USE=threads is disabled"
		die "invalid use flag combination"
	fi

	if has ${MY_MPM} ${IUSE_MPMS_FORK} && use threads ; then
		eerror "You have selected a non-threaded MPM but USE=threads is enabled"
		die "invalid use flag combination"
	fi
}

# @ECLASS-VARIABLE: MODULE_DEPENDS
# @DESCRIPTION:
# This variable needs to be set in the ebuild and contains a space-separated
# list of dependency tokens each with a module and the module it depends on
# separated by a colon

# @FUNCTION: check_module_depends
# @DESCRIPTION:
# This internal function makes sure that all inter-module dependencies are
# satisfied with the current module selection
check_module_depends() {
	local err=0

	for m in ${MY_MODS} ; do
		for dep in ${MODULE_DEPENDS} ; do
			if [[ "${m}" == "${dep%:*}" ]]; then
				if ! use apache2_modules_${dep#*:} ; then
					eerror "Module '${m}' depends on '${dep#*:}'"
					err=1
				fi
			fi
		done
	done

	if [[ ${err} -ne 0 ]] ; then
		die "invalid use flag combination"
	fi
}

# @ECLASS-VARIABLE: MY_CONF
# DESCRIPTION:
# This internal variable contains the econf options for the current module
# selection after a call to setup_modules()

# @ECLASS-VARIABLE: MY_MODS
# DESCRIPTION:
# This internal variable contains a sorted, space separated list of currently
# selected modules after a call to setup_modules()

# @FUNCTION: setup_modules
# @DESCRIPTION:
# This internal function selects all built-in modules based on USE flags and
# APACHE2_MODULES USE_EXPAND flags
setup_modules() {
	local mod_type=

	if use static ; then
		mod_type="static"
	else
		mod_type="shared"
	fi

	MY_CONF="--enable-so=static"

	if use ldap ; then
		if ! built_with_use 'dev-libs/apr-util' ldap ; then
			eerror "dev-libs/apr-util is missing LDAP support. For apache to have"
			eerror "ldap support, apr-util must be built with the ldap USE-flag"
			eerror "enabled."
			die "ldap USE-flag enabled while not supported in apr-util"
		fi
		MY_CONF="${MY_CONF} --enable-authnz_ldap=${mod_type} --enable-ldap=${mod_type}"
		MY_MODS="${MY_MODS} ldap authnz_ldap"
	else
		MY_CONF="${MY_CONF} --disable-authnz_ldap --disable-ldap"
	fi

	if use ssl ; then
		MY_CONF="${MY_CONF} --with-ssl=/usr --enable-ssl=${mod_type}"
		MY_MODS="${MY_MODS} ssl"
	else
		MY_CONF="${MY_CONF} --without-ssl --disable-ssl"
	fi

	if use threads || has ${MY_MPM} ${IUSE_MPMS_THREAD} ; then
		MY_CONF="${MY_CONF} --enable-cgid=${mod_type}"
		MY_MODS="${MY_MODS} cgid"
	else
		MY_CONF="${MY_CONF} --enable-cgi=${mod_type}"
		MY_MODS="${MY_MODS} cgi"
	fi

	if use suexec ; then
		elog "You can manipulate several configure options of suexec"
		elog "through the following environment variables:"
		elog
		elog " SUEXEC_SAFEPATH: Default PATH for suexec (default: /usr/local/bin:/usr/bin:/bin)"
		elog "  SUEXEC_LOGFILE: Path to the suexec logfile (default: /var/log/apache2/suexec_log)"
		elog "   SUEXEC_CALLER: Name of the user Apache is running as (default: apache)"
		elog "  SUEXEC_DOCROOT: Directory in which suexec will run scripts (default: /var/www)"
		elog "   SUEXEC_MINUID: Minimum UID, which is allowed to run scripts via suexec (default: 1000)"
		elog "   SUEXEC_MINGID: Minimum GID, which is allowed to run scripts via suexec (default: 100)"
		elog "  SUEXEC_USERDIR: User subdirectories (like /home/user/html) (default: public_html)"
		elog "    SUEXEC_UMASK: Umask for the suexec process (default: 077)"
		elog

		MY_CONF="${MY_CONF} --with-suexec-safepath=${SUEXEC_SAFEPATH:-/usr/local/bin:/usr/bin:/bin}"
		MY_CONF="${MY_CONF} --with-suexec-logfile=${SUEXEC_LOGFILE:-/var/log/apache2/suexec_log}"
		MY_CONF="${MY_CONF} --with-suexec-bin=/usr/sbin/suexec"
		MY_CONF="${MY_CONF} --with-suexec-userdir=${SUEXEC_USERDIR:-public_html}"
		MY_CONF="${MY_CONF} --with-suexec-caller=${SUEXEC_CALLER:-apache}"
		MY_CONF="${MY_CONF} --with-suexec-docroot=${SUEXEC_DOCROOT:-/var/www}"
		MY_CONF="${MY_CONF} --with-suexec-uidmin=${SUEXEC_MINUID:-1000}"
		MY_CONF="${MY_CONF} --with-suexec-gidmin=${SUEXEC_MINGID:-100}"
		MY_CONF="${MY_CONF} --with-suexec-umask=${SUEXEC_UMASK:-077}"
		MY_CONF="${MY_CONF} --enable-suexec=${mod_type}"
		MY_MODS="${MY_MODS} suexec"
	else
		MY_CONF="${MY_CONF} --disable-suexec"
	fi

	for x in ${IUSE_MODULES} ; do
		if use apache2_modules_${x} ; then
			MY_CONF="${MY_CONF} --enable-${x}=${mod_type}"
			MY_MODS="${MY_MODS} ${x}"
		else
			MY_CONF="${MY_CONF} --disable-${x}"
		fi
	done

	# sort and uniquify MY_MODS
	MY_MODS=$(echo ${MY_MODS} | tr ' ' '\n' | sort -u)
	check_module_depends
}

# @ECLASS-VARIABLE: MODULE_DEFINES
# @DESCRIPTION:
# This variable needs to be set in the ebuild and contains a space-separated
# list of tokens each mapping a module to a runtime define which can be
# specified in APACHE2_OPTS in /etc/conf.d/apache2 to enable this particular
# module.

# @FUNCTION: generate_load_module
# @DESCRIPTION:
# This internal function generates the LoadModule lines for httpd.conf based on
# the current module selection and MODULE_DEFINES
generate_load_module() {
	local endit=0 mod_lines= mod_dir="${D}${APACHE2_MODULESDIR}"

	if use static; then
		sed -i -e "/%%LOAD_MODULE%%/d" \
			"${GENTOO_PATCHDIR}"/conf/httpd.conf
		return
	fi

	for m in ${MY_MODS} ; do
		if [[ -e "${mod_dir}/mod_${m}.so" ]] ; then
			for def in ${MODULE_DEFINES} ; do
				if [[ "${m}" == "${def%:*}" ]] ; then
					mod_lines="${mod_lines}\n<IfDefine ${def#*:}>"
					endit=1
				fi
			done

			mod_lines="${mod_lines}\nLoadModule ${m}_module modules/mod_${m}.so"

			if [[ ${endit} -ne 0 ]] ; then
				mod_lines="${mod_lines}\n</IfDefine>"
				endit=0
			fi
		fi
	done

	sed -i -e "s:%%LOAD_MODULE%%:${mod_lines}:" \
		"${GENTOO_PATCHDIR}"/conf/httpd.conf
}

# @FUNCTION: check_upgrade
# @DESCRIPTION:
# This internal function checks if the previous configuration file for built-in
# modules exists in ROOT and prevents upgrade in this case. Users are supposed
# to convert this file to the new APACHE2_MODULES USE_EXPAND variable and remove
# it afterwards.
check_upgrade() {
	if [[ -e "${ROOT}"etc/apache2/apache2-builtin-mods ]]; then
		eerror "The previous configuration file for built-in modules"
		eerror "(${ROOT}etc/apache2/apache2-builtin-mods) exists on your"
		eerror "system."
		eerror
		eerror "Please read http://www.gentoo.org/proj/en/apache/upgrade.xml"
		eerror "for detailed information how to convert this file to the new"
		eerror "APACHE2_MODULES USE_EXPAND variable."
		eerror
		die "upgrade not possible with existing ${ROOT}etc/apache2/apache2-builtin-mods"
	fi
}

# ==============================================================================
# EXPORTED FUNCTIONS
# ==============================================================================

# @FUNCTION: apache-2_pkg_setup
# @DESCRIPTION:
# This function selects built-in modules, the MPM and other configure options,
# creates the apache user and group and informs about CONFIG_SYSVIPC being
# needed (we don't depend on kernel sources and therefore cannot check).
apache-2_pkg_setup() {
	check_upgrade

	setup_mpm
	setup_modules

	if use debug; then
		MY_CONF="${MY_CONF} --enable-maintainer-mode --enable-exception-hook"
	fi

	# setup apache user and group
	enewgroup apache 81
	enewuser apache 81 -1 /var/www apache

	elog "Please note that you need SysV IPC support in your kernel."
	elog "Make sure CONFIG_SYSVIPC=y is set."
	elog
}

# @FUNCTION: apache-2_src_unpack
# @DESCRIPTION:
# This function applies patches, configures a custom file-system layout and
# rebuilds the configure scripts. The patch names are organized as follows:
#
# 00-19 Gentoo specific  (00_all_some-title.patch)
# 20-39 Additional MPMs  (20_all_${MPM}_some-title.patch)
# 40-59 USE-flag based   (40_all_${USE}_some-title.patch)
# 60-79 Version specific (60_all_${PV}_some-title.patch)
# 80-99 Security patches (80_all_${PV}_cve-####-####.patch)
apache-2_src_unpack() {
	unpack ${A}
	cd "${S}"

	# Use correct multilib libdir in gentoo patches
	sed -i -e "s:/usr/lib:/usr/$(get_libdir):g" \
		"${GENTOO_PATCHDIR}"/{conf/httpd.conf,init/*,patches/config.layout} \
		|| die "libdir sed failed"

	epatch "${GENTOO_PATCHDIR}"/patches/*.patch

	# setup the filesystem layout config
	cat "${GENTOO_PATCHDIR}"/patches/config.layout >> "${S}"/config.layout || \
		die "Failed preparing config.layout!"
	sed -i -e "s:version:${PF}:g" "${S}"/config.layout

	# patched-in MPMs need the build environment rebuilt
	sed -i -e '/sinclude/d' configure.in
	AT_GNUCONF_UPDATE=yes AT_M4DIR=build eautoreconf

	# apache2.8 instead of httpd.8 (bug #194828)
	mv docs/man/{httpd,apache2}.8
}

# @FUNCTION: apache-2_src_compile
# @DESCRIPTION:
# This function adds compiler flags and runs econf and emake based on MY_MPM and
# MY_CONF
apache-2_src_compile() {
	# Instead of filtering --as-needed (bug #128505), append --no-as-needed
	# Thanks to Harald van Dijk
	append-ldflags -Wl,--no-as-needed

	# peruser MPM debugging with -X is nearly impossible
	if has peruser ${IUSE_MPMS} && use apache2_mpms_peruser ; then
		use debug && append-flags -DMPM_PERUSER_DEBUG
	fi

	# econf overwrites the stuff from config.layout, so we have to put them into
	# our myconf line too
	econf \
		--includedir=/usr/include/apache2 \
		--libexecdir=/usr/$(get_libdir)/apache2/modules \
		--datadir=/var/www/localhost \
		--sysconfdir=/etc/apache2 \
		--localstatedir=/var \
		--with-mpm=${MY_MPM} \
		--with-perl=/usr/bin/perl \
		--with-apr=/usr \
		--with-apr-util=/usr \
		--with-pcre=/usr \
		--with-z=/usr \
		--with-port=80 \
		--with-program-name=apache2 \
		--enable-layout=Gentoo \
		${MY_CONF} || die "econf failed!"

	sed -i -e 's:apache2\.conf:httpd.conf:' include/ap_config_auto.h

	emake || die "emake failed"
}

# @FUNCTION: apache-2_src_install
# @DESCRIPTION:
# This function runs emake install and generates, install and adapts the gentoo
# specific configuration files found in the tarball
apache-2_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# install our configuration files
	keepdir /etc/apache2/vhosts.d
	keepdir /etc/apache2/modules.d

	generate_load_module
	insinto /etc/apache2
	doins -r "${GENTOO_PATCHDIR}"/conf/*
	doins docs/conf/magic

	insinto /etc/logrotate.d
	newins "${GENTOO_PATCHDIR}"/scripts/apache2-logrotate apache2

	# generate a sane default APACHE2_OPTS
	APACHE2_OPTS="-D DEFAULT_VHOST -D INFO -D LANGUAGE"
	use doc && APACHE2_OPTS="${APACHE2_OPTS} -D MANUAL"
	use ssl && APACHE2_OPTS="${APACHE2_OPTS} -D SSL -D SSL_DEFAULT_VHOST"
	use suexec && APACHE2_OPTS="${APACHE2_OPTS} -D SUEXEC"

	sed -i -e "s:APACHE2_OPTS=\".*\":APACHE2_OPTS=\"${APACHE2_OPTS}\":" \
		"${GENTOO_PATCHDIR}"/init/apache2.confd || die "sed failed"

	newconfd "${GENTOO_PATCHDIR}"/init/apache2.confd apache2
	newinitd "${GENTOO_PATCHDIR}"/init/apache2.initd apache2

	# link apache2ctl to the init script
	dosym /etc/init.d/apache2 /usr/sbin/apache2ctl

	# provide symlinks for all the stuff we no longer rename, bug 177697
	for i in suexec apxs; do
		dosym /usr/sbin/${i} /usr/sbin/${i}2
	done

	# install some thirdparty scripts
	exeinto /usr/sbin
	use ssl && doexe "${GENTOO_PATCHDIR}"/scripts/gentestcrt.sh

	# install some documentation
	dodoc ABOUT_APACHE CHANGES LAYOUT README README.platforms VERSIONING
	dodoc "${GENTOO_PATCHDIR}"/docs/*

	# drop in a convenient link to the manual
	if use doc ; then
		sed -i -e "s:VERSION:${PVR}:" "${D}/etc/apache2/modules.d/00_apache_manual.conf"
	else
		rm -f "${D}/etc/apache2/modules.d/00_apache_manual.conf"
		rm -Rf "${D}/usr/share/doc/${PF}/manual"
	fi

	# the default webroot gets stored in /usr/share/doc
	ebegin "Installing default webroot to /usr/share/doc/${PF}"
	mv -f "${D}/var/www/localhost" "${D}/usr/share/doc/${PF}/webroot"
	eend $?
	keepdir /var/www/localhost/htdocs

	# set some sane permissions for suexec
	if use suexec ; then
		fowners 0:apache /usr/sbin/suexec
		fperms 4710 /usr/sbin/suexec
	fi

	# empty dirs
	for i in /var/lib/dav /var/log/apache2 /var/cache/apache2 ; do
		keepdir ${i}
		fowners apache:apache ${i}
		fperms 0755 ${i}
	done

	# we need /etc/apache2/ssl if USE=ssl
	use ssl && keepdir /etc/apache2/ssl
}

# @FUNCTION: apache-2_pkg_postinst
# @DESCRIPTION:
# This function creates test certificates if SSL is enabled and installs the
# default webroot if /var/www/localhost does not exist. We do this here because
# the default webroot is a copy of the files that exist elsewhere and we don't
# want them to be managed/removed by portage when apache is upgraded.
apache-2_pkg_postinst() {
	if use ssl && [[ ! -e "${ROOT}/etc/apache2/ssl/server.crt" ]] ; then
		cd "${ROOT}"/etc/apache2/ssl
		einfo
		einfo "Generating self-signed test certificate in ${ROOT}etc/apache2/ssl ..."
		yes "" 2>/dev/null | \
			"${ROOT}"/usr/sbin/gentestcrt.sh >/dev/null 2>&1 || \
			die "gentestcrt.sh failed"
		einfo
	fi

	if [[ -e "${ROOT}/var/www/localhost" ]] ; then
		elog "The default webroot has not been installed into"
		elog "${ROOT}var/www/localhost because the directory already exists"
		elog "and we do not want to overwrite any files you have put there."
		elog
		elog "If you would like to install the latest webroot, please run"
		elog "emerge --config =${PF}"
		elog
	else
		einfo "Installing default webroot to ${ROOT}var/www/localhost"
		mkdir -p "${ROOT}"/var/www/localhost
		cp -R "${ROOT}"/usr/share/doc/${PF}/webroot/* "${ROOT}"/var/www/localhost
		chown -R apache:0 "${ROOT}"/var/www/localhost
	fi
}

# @FUNCTION: apache-2_pkg_config
# @DESCRIPTION:
# This function installs -- and removes a previously existing -- default webroot
# to /var/www/localhost
apache-2_pkg_config() {
	einfo "Installing default webroot to ${ROOT}var/www/localhost"
	mkdir "${ROOT}"var{,/www{,/localhost}}
	cp -R "${ROOT}"usr/share/doc/${PF}/webroot/* "${ROOT}"var/www/localhost/
}

EXPORT_FUNCTIONS pkg_setup src_unpack src_compile src_install pkg_postinst pkg_config
