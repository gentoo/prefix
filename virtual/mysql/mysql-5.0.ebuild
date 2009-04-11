# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/mysql/mysql-5.0.ebuild,v 1.5 2007/05/17 08:39:40 kloeri Exp $

DESCRIPTION="Virtual for MySQL client or database"
HOMEPAGE="http://dev.mysql.com"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND="|| (
	=dev-db/mysql-${PV}*
	=dev-db/mysql-community-${PV}*
)"
