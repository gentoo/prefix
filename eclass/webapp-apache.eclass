# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/webapp-apache.eclass,v 1.27 2007/05/12 02:54:35 chtekk Exp $
#
# Author: Stuart Herbert <stuart@gentoo.org>
#
# Based on discussions held on gentoo-dev mailing list, and a bug report
# contributed by Ian Leitch <port001@w0r.mine.nu> in bug #14870,
# and robbat2's mod_php ebuild
#
# This package will be offically depreciated when vhost-config and
# webapp-config from GLEP11 are released.

IUSE="apache2"
DEPEND="${DEPEND} net-www/apache"

EXPORT_FUNCTIONS pkg_setup

# NOTE:
#
# It is deliberate that the functions in this eclass are called
# 'webapp-xxx' rather than 'webapp-apache-xxx'.  This ensures
# that we can drop in eclasses for other web servers without
# having to change the ebuilds!

function webapp-apache-detect ()
{
	APACHEVER=
	has_version '=net-www/apache-2*' && APACHEVER=2 && CONFVER=2
	[ -z "${APACHEVER}" ] && has_version '=net-www/apache-2*' && APACHEVER=2 && CONFVER=2

	if [ "${APACHEVER}+" = "+" ]; then
		# no apache version detected
		return 1
	fi

	APACHECONF="/etc/apache${CONFVER}/conf/apache${CONFVER}.conf"
	APACHECONF_COMMON="/etc/apache${CONFVER}/conf/commonapache${CONFVER}.conf"
	APACHECONF_DIR="/etc/apache${CONFVER}/conf/"
	WEBAPP_SERVER="Apache v${APACHEVER}"
}

# run the function, so we know which version of apache we are using

function webapp-detect () {
	webapp-apache-detect || return 1
	webapp-determine-installowner
	webapp-determine-htdocsdir
	webapp-determine-cgibindir

	# explicit return here to ensure the return code
	# from webapp-determine-cgibindir above isn't returned instead

	return 0
}

function webapp-mkdirs () {
	webapp-determine-htdocsdir
	webapp-determine-cgibindir

	keepdir "$HTTPD_ROOT"
	fowners "$HTTPD_USER":"$HTTPD_GROUP" "$HTTPD_ROOT"
	fperms 755 "$HTTPD_ROOT"

	# explicit return here to ensure the return code
	# from above isn't returned instead

	return 0
}

function webapp-determine-htdocsdir ()
{
	webapp-determine-installowner

#	HTTPD_ROOT="`grep '^DocumentRoot' ${APACHECONF} | cut -d ' ' -f 2`"
#    [ -z "${HTTPD_ROOT}" ] && HTTPD_ROOT="/home/httpd/htdocs/"
	# temporary fix for webapps
	HTTPD_ROOT="/var/www/localhost/htdocs/"
}

function webapp-determine-cgibindir ()
{
	#HTTPD_CGIBIN="`grep 'ScriptAlias /cgi-bin/' ${APACHECONF_COMMON} | cut -d ' ' -f 7`"
	#[ -z "${HTTPD_CGIBIN}" ] && HTTPD_CGIBIN="/home/httpd/cgi-bin/"
	# temporary fix for webapps
	HTTPD_CGIBIN="/var/www/localhost/cgi-bin/"
}

function webapp-determine-installowner ()
{
	HTTPD_USER="apache"
	HTTPD_GROUP="apache"
}


function webapp-pkg_setup ()
{
	if [ "$1" == "1" ]; then
		msg="I couldn't find an installation of Apache"
		eerror "${msg}"
		die "${msg}"
	fi

	ewarn "Ebuilds (like this one) that use the webapp-apache.eclass need to"
	ewarn "be converted to use the new webapp.eclass, to be compatible with"
	ewarn "webapp-config."
	ewarn
	ewarn "Please file a bug on http://bugs.gentoo.org/, stating that this"
	ewarn "ebuild needs converting to use the new approach."
}
