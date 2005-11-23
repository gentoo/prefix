# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/psycopg/psycopg-1.1.21.ebuild,v 1.2 2005/11/14 16:53:36 seemant Exp $

EAPI="prefix"

inherit python

DESCRIPTION="PostgreSQL database adapter for Python" # best one
SRC_URI="http://initd.org/pub/software/psycopg/${P}.tar.gz"
HOMEPAGE="http://www.initd.org/software/psycopg"

DEPEND="virtual/python
	>=dev-python/egenix-mx-base-2.0.3
	>=dev-db/postgresql-7.1.3"

SLOT="0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc-macos ~sparc ~x86"
LICENSE="GPL-2"
IUSE=""

src_compile() {
	python_version
	econf \
		--with-mxdatetime-includes=${PREFIX}/usr/lib/python${PYVER}/site-packages/mx/DateTime/mxDateTime \
		--with-postgres-includes=${PREFIX}/usr/include/postgresql/server \
		|| die "./configure failed"
	emake || die
}

src_install () {
	cd ${S}
	sed -e -i 's:^PY_MOD_DIR =:PY_MOD_DIR = $(PY_LIB_DIR):' Makefile
	sed -e 's:^PY_MOD_DIR = $(exec_prefix):PY_MOD_DIR = $(PY_LIB_DIR):' \
		-e 's:\(echo "  install -m 555 $$mod \)\($(PY_MOD_DIR)\)\("; \\\):\1${DEST}\2/$$mod\3:' \
		-e 's:\($(INSTALL)  -m 555 $$mod \)\($(PY_MOD_DIR)\)\(; \\\):\1${DEST}\2/$$mod\3:' \
		-i Makefile
	make install || die

	dodoc AUTHORS ChangeLog COPYING CREDITS INSTALL README NEWS RELEASE-1.0 SUCCESS TODO
	docinto doc
	dodoc   doc/*
	insinto /usr/share/doc/${PF}/examples
	doins   doc/examples/*
}
