# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/virtual/postgresql-server/postgresql-server-8.3.ebuild,v 1.2 2008/05/19 07:13:12 dev-zero Exp $

EAPI=1

DESCRIPTION="Virtual for PostgreSQL libraries"
HOMEPAGE="http://www.postgresql.org/"
SRC_URI=""

LICENSE="as-is"
SLOT="${PV}"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="|| ( =dev-db/postgresql-${PV}* dev-db/postgresql-server:${SLOT} )"
