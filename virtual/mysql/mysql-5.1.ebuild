# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/mysql/mysql-5.1.ebuild,v 1.3 2006/11/23 15:57:58 chtekk Exp $

DESCRIPTION="Virtual for MySQL client or database"
HOMEPAGE="http://dev.mysql.com"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="|| (
	=dev-db/mysql-${PV}*
	=dev-db/mysql-community-${PV}*
)"
