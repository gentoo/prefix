# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/psycopg/psycopg-2.0.7.ebuild,v 1.1 2008/05/26 12:46:54 nelchael Exp $

EAPI="prefix"

NEED_PYTHON=2.4

inherit eutils distutils

MY_P=${PN}2-${PV}

DESCRIPTION="PostgreSQL database adapter for Python."
SRC_URI="http://initd.org/pub/software/psycopg/${MY_P}.tar.gz"
HOMEPAGE="http://initd.org/projects/psycopg2"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
LICENSE="GPL-2"
IUSE="debug doc examples mxdatetime"

DEPEND="virtual/postgresql-base
	mxdatetime? ( dev-python/egenix-mx-base )"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

PYTHON_MODNAME=${PN}2

src_unpack() {
	unpack ${A}
	cd "${S}"

	if use debug; then
		sed -i 's/^\(define=\)/\1PSYCOPG_DEBUG,/' setup.cfg || die "sed failed"
	fi

	if use mxdatetime; then
		sed -i 's/\(use_pydatetime=\)1/\10/' setup.cfg || die "sed failed"
	fi

	# Fixes compilation issue in fbsd.
	epatch "${FILESDIR}/${P}-fbsd.patch"
	# ... and also fix it on Solaris (the same way)
	epatch "${FILESDIR}"/${PN}-2.0.6-use-configure-or-die.patch
}

src_install() {
	DOCS="AUTHORS doc/HACKING doc/SUCCESS doc/TODO doc/async.txt"
	distutils_src_install

	insinto /usr/share/doc/${PF}
	use examples && doins -r examples

	cd doc
	use doc && dohtml -r .
}
