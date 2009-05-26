# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/celementtree/celementtree-1.0.5-r1.ebuild,v 1.8 2009/05/25 13:52:22 armin76 Exp $

inherit distutils eutils

MY_P="cElementTree-${PV}-20051216"
DESCRIPTION="The cElementTree module is a C implementation of the ElementTree API"
HOMEPAGE="http://effbot.org/zone/celementtree.htm"
SRC_URI="http://effbot.org/downloads/${MY_P}.tar.gz"

LICENSE="ElementTree"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"

IUSE="doc"
DEPEND="dev-python/setuptools"
RDEPEND=">=dev-lang/python-2.1.3-r1
	>=dev-python/elementtree-1.2
	>=dev-libs/expat-1.95.8"
S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-use_system_expat.patch"
	epatch "${FILESDIR}/${P}-setuptools.patch"
}

src_install() {
	distutils_src_install
	if use doc; then
		insinto /usr/share/doc/${PF}/samples
		doins samples/*
		doins selftest.py
	fi
}

src_test() {
	PYTHONPATH="$(ls -d build/lib.*)" "${python}" selftest.py \
		|| die "tests failed"
}
