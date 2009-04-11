# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/soappy/soappy-0.12.0.ebuild,v 1.11 2009/03/14 17:41:34 armin76 Exp $

inherit distutils

MY_PN="SOAPpy"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="SOAP implementation for Python"
HOMEPAGE="http://pywebsvcs.sourceforge.net/"
SRC_URI="mirror://sourceforge/pywebsvcs/${MY_P}.tar.gz"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
SLOT="0"
LICENSE="BSD"
IUSE="examples ssl"

DEPEND=">=dev-python/fpconst-0.7.1
		dev-python/pyxml"
RDEPEND="${DEPEND}
	ssl? ( dev-python/m2crypto )"

S=${WORKDIR}/${MY_P}
PYTHON_MODNAME=${MY_PN}
DOCS="RELEASE_INFO"

pkg_setup() {
	if use ssl && ! built_with_use dev-lang/python ssl ; then
		ewarn "The 'ssl' USE-flag is enabled, but dev-lang/python is"
		ewarn "not compiled with it. You'll only get server-side SSL support."
		ewarn "Just emerge dev-lang/python afterwards with the ssl USE-flag to"
		ewarn "get client-side encryption."
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-python-2.5-compat.patch"
}

src_install() {
	distutils_src_install
	dodoc docs/*
	if use examples ; then
		insinto /usr/share/doc/${PF}/examples
		doins -r contrib bid tools validate
	fi
}
