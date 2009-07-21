# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/java-virtuals/servlet-api/servlet-api-2.2.ebuild,v 1.10 2009/07/19 14:07:12 nixnut Exp $

EAPI=1

inherit java-virtuals-2

DESCRIPTION="Virtual for servlet api"
HOMEPAGE="http://java.sun.com/products/servlet/"
SRC_URI=""

LICENSE="as-is"
SLOT="${PV}"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="dev-java/tomcat-servlet-api:${SLOT}"
DEPEND=""

JAVA_VIRTUAL_PROVIDES="tomcat-servlet-api-${SLOT}"
