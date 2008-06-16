# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/apache/apache-2.2.9.ebuild,v 1.4 2008/06/16 00:17:11 jer Exp $

EAPI="prefix"

# latest gentoo apache files
GENTOO_PATCHSTAMP="20080615"
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

# some helper scripts are Apache-1.1, thus both are here
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

pkg_preinst() {
	# note regarding IfDefine changes
	if has_version "<${CATEGORY}/${PN}-2.2.6-r1"; then
		elog
		elog "When upgrading from versions 2.2.6 or earlier, please be aware"
		elog "that the define for mod_authnz_ldap has changed from AUTH_LDAP"
		elog "to AUTHNZ_LDAP. Additionally mod_auth_digest needs to be enabled"
		elog "with AUTH_DIGEST now."
		elog
	fi
}
