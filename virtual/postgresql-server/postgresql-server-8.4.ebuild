# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/postgresql-server/postgresql-server-8.4.ebuild,v 1.3 2009/10/13 15:25:04 jer Exp $

EAPI=1

DESCRIPTION="Virtual for PostgreSQL libraries"
HOMEPAGE="http://www.postgresql.org/"
SRC_URI=""

LICENSE="as-is"
SLOT="${PV}"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="dev-db/postgresql-server:${SLOT}"
