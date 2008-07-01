# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/virtual/httpd-cgi/httpd-cgi-0.ebuild,v 1.2 2008/01/06 18:42:16 wltjr Exp $

EAPI="prefix"

DESCRIPTION="Virtual for CGI-enabled webservers"
HOMEPAGE="http://gentoo.org/"
SRC_URI=""

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="|| (
	www-servers/apache
	www-servers/lighttpd
	www-servers/boa
	www-servers/bozohttpd
	www-servers/cherokee
	www-servers/fnord
	www-servers/mini_httpd
	www-servers/monkeyd
	www-servers/nginx
	www-servers/orion
	www-servers/resin
	www-servers/shttpd
	www-servers/skunkweb
	www-servers/thttpd
	www-servers/tomcat
	www-servers/tux
	www-servers/yaws
	)"
DEPEND=""
