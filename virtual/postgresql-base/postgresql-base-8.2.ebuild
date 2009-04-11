# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/virtual/postgresql-base/postgresql-base-8.2.ebuild,v 1.1 2008/04/15 09:41:07 dev-zero Exp $

EAPI=1

DESCRIPTION="Virtual for PostgreSQL base (clients + libraries)"
HOMEPAGE="http://www.postgresql.org/"
SRC_URI=""

LICENSE="as-is"
SLOT="${PV}"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="|| ( =dev-db/libpq-${PV}* dev-db/postgresql-base:${SLOT} )"
