# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/apache/apache-2.2.8-r4.ebuild,v 1.1 2008/06/11 19:08:59 hollow Exp $

EAPI="prefix"

# latest gentoo apache files
GENTOO_PATCHSTAMP="20080611"
GENTOO_DEVELOPER="hollow"

# IUSE/USE_EXPAND magic
IUSE_MPMS_FORK="itk peruser prefork"
IUSE_MPMS_THREAD="event worker"

IUSE_MODULES="actions alias asis auth_basic auth_digest authn_alias authn_anon
authn_dbd authn_dbm authn_default authn_file authz_dbm authz_default
authz_groupfile authz_host authz_owner authz_user autoindex cache cern_meta
charset_lite dav dav_fs dav_lock dbd deflate dir disk_cache dumpio env expires
ext_filter file_cache filter headers ident imagemap include info log_config
log_forensic logio mem_cache mime mime_magic negotiation proxy proxy_ajp
proxy_balancer proxy_connect proxy_ftp proxy_http rewrite setenvif speling
status substitute unique_id userdir usertrack version vhost_alias"

# inter-module dependencies
# TODO: this may still be incomplete
MODULE_DEPENDS="
	dav_fs:dav
	dav_lock:dav
	deflate:filter
	disk_cache:cache
	ext_filter:filter
	file_cache:cache
	log_forensic:log_config
	logio:log_config
	mem_cache:cache
	mime_magic:mime
	proxy_ajp:proxy
	proxy_balancer:proxy
	proxy_connect:proxy
	proxy_ftp:proxy
	proxy_http:proxy
	substitute:filter
"

# module<->define mappings
MODULE_DEFINES="
	auth_digest:AUTH_DIGEST
	authnz_ldap:AUTHNZ_LDAP
	cache:CACHE
	dav:DAV
	dav_fs:DAV
	dav_lock:DAV
	disk_cache:CACHE
	file_cache:CACHE
	info:INFO
	ldap:LDAP
	mem_cache:CACHE
	proxy:PROXY
	proxy_ajp:PROXY
	proxy_balancer:PROXY
	proxy_connect:PROXY
	proxy_ftp:PROXY
	proxy_http:PROXY
	ssl:SSL
	status:STATUS
	suexec:SUEXEC
	userdir:USERDIR
"

# critical modules for the default config
MODULE_CRITICAL="
	authz_host
	dir
	mime
"

inherit eutils apache-2

DESCRIPTION="The Apache Web Server."
HOMEPAGE="http://httpd.apache.org/"

# some helper scripts are apache-1.1, thus both are here
LICENSE="Apache-2.0 Apache-1.1"
SLOT="2"
# entirely new, based on eclass that probably needs fixin...
KEYWORDS=""
IUSE="sni"

DEPEND="${DEPEND}
	apache2_modules_deflate? ( sys-libs/zlib )"

RDEPEND="${RDEPEND}
	apache2_modules_mime? ( app-misc/mime-types )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	pushd "${GENTOO_PATCHDIR}"
		epatch "${FILESDIR}"/${PN}-2.2.6-prefix.patch
		eprefixify \
			conf/httpd.conf \
			scripts/gentestcrt.sh \
			docs/ip-based-vhost.conf.example \
			docs/name-based-vhost.conf.example \
			docs/ssl-vhost.conf.example \
			patches/config.layout \
			scripts/apache2-logrotate \
			init/apache2.initd \
			conf/vhosts.d/00_default_ssl_vhost.conf \
			conf/vhosts.d/00_default_vhost.conf \
			conf/vhosts.d/default_vhost.include \
			conf/modules.d/00_apache_manual.conf \
			conf/modules.d/00_autoindex.conf \
			conf/modules.d/00_error_documents.conf \
			conf/modules.d/00_mod_log_config.conf \
			conf/modules.d/00_mod_mime.conf \
			conf/modules.d/00_mpm.conf \
			conf/modules.d/40_mod_ssl.conf \
			conf/modules.d/45_mod_dav.conf
	popd

	# 03_all_gentoo-apache-tools.patch injects -Wl,-z,now, which is not a good
	# idea for everyone
	case ${CHOST} in
		*-linux-gnu|*-solaris*|*-freebsd*)
			# do nothing, these use GNU binutils
			:
		;;
		*-darwin*)
			sed -i -e 's/-Wl,-z,now/-Wl,-bind_at_load/g' \
				"${GENTOO_PATCHDIR}"/patches/03_all_gentoo-apache-tools.patch
		;;
		*)
			# patch it out to be like upstream
			sed -i -e 's/-Wl,-z,now//g' \
				"${GENTOO_PATCHDIR}"/patches/03_all_gentoo-apache-tools.patch
		;;
	esac

	# Use correct multilib libdir in gentoo patches
	sed -i -e "s:/usr/lib:/usr/$(get_libdir):g" \
		"${GENTOO_PATCHDIR}"/{conf/httpd.conf,init/*,patches/config.layout} \
		|| die "libdir sed failed"

	if ! use sni ; then
		EPATCH_EXCLUDE="04_all_mod_ssl_tls_sni.patch"
	fi

	apache-2_src_unpack
}

pkg_postinst() {
	apache-2_pkg_postinst

	# previous installations of apache-2.2 installed the upstream configuration
	# files, which shouldn't even have been installed!
	if has_version '>=www-servers/apache-2.2.4' ; then
		if [[ -f "${EROOT}"etc/apache2/apache2.conf ]] ; then
			rm -f "${EROOT}"/etc/apache2/apache2.conf >/dev/null 2>&1
		fi

		for i in extra original ; do
			if [[ -d "${EROOT}"/etc/apache2/${i} ]] ; then
				rm -rf "${EROOT}"/etc/apache2/${i} >/dev/null 2>&1
			fi
		done
	fi

	# note regarding IfDefine changes
	if has_version '<www-servers/apache-2.2.6-r1' ; then
		elog
		elog "When upgrading from versions 2.2.6 or earlier, please be aware"
		elog "that the define for mod_authnz_ldap has changed from AUTH_LDAP"
		elog "to AUTHNZ_LDAP. Additionally mod_auth_digest needs to be enabled"
		elog "with AUTH_DIGEST now."
		elog
	fi

	# note the changes regarding DEFAULT_VHOST and SSL_DEFAULT_VHOST
	if has_version '<www-servers/apache-2.2.4-r7' ; then
		elog
		elog "Listen directives have been moved into the default virtual host"
		elog "configuation. At least DEFAULT_VHOST has been enabled for you"
		elog "(depending on your USE-flags.)"
		elog
		elog "If you disable DEFAULT_VHOST or SSL_DEFAULT_VHOST, there will"
		elog "be no listening sockets available."
		elog
	fi

	# note the user of the config changes
	if has_version '<www-servers/apache-2.2.4-r5' ; then
		elog
		elog "Please make sure that you update your /etc directory."
		elog "Between the versions, we had to changes some config files"
		elog "and move some stuff out of the main httpd.conf file to a seperate"
		elog "modules.d entry."
		elog
		elog "Thus please update your /etc directory either via etc-update,"
		elog "dispatch-conf or conf-update !"
		elog
	fi

	# check for dual/upgrade install
	if has_version '<www-servers/apache-2.2.0' ; then
		elog
		elog "When upgrading from versions below 2.2.0 to this version, you"
		elog "need to rebuild all your modules. Please do so for your modules"
		elog "to continue working correctly."
		elog
		elog "Also note that some configuration directives have been"
		elog "split into their own files under ${EROOT}etc/apache2/modules.d/"
		elog "and that some modules, foremost the authentication related ones,"
		elog "have been renamed."
		elog
		elog "Some examples:"
		elog "  - USERDIR is now configureable in ${EROOT}etc/apache2/modules.d/00_mod_userdir.conf."
		elog
		elog "For more information on what you may need to change, please"
		elog "see the overview of changes at:"
		elog "http://httpd.apache.org/docs/2.2/new_features_2_2.html"
		elog "and the upgrading guide at:"
		elog "http://httpd.apache.org/docs/2.2/upgrading.html"
		elog
	fi

	# cleanup the vim backup files, placed in /etc/apache2 by the last
	# patchtarball (gentoo-apache-2.2.4-r7-20070615)
	rm -f "${EROOT}etc/apache2/modules.d/*.conf~"
}
