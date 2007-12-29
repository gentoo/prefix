# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/elementtree/elementtree-1.2.6-r2.ebuild,v 1.8 2007/12/27 17:01:52 ranger Exp $

EAPI="prefix"

inherit distutils

MY_P="${PN}-${PV}-20050316"
DESCRIPTION="A light-weight XML object model for Python"
HOMEPAGE="http://effbot.org/zone/element-index.htm"
SRC_URI="http://effbot.org/downloads/${MY_P}.tar.gz"

LICENSE="ElementTree"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~sparc-solaris ~x86 ~x86-macos"
IUSE=""
DEPEND="dev-python/setuptools"
S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd ${S}
	sed -i -e 's/distutils.core/setuptools/' setup.py || die 'sed failed'
}

src_test() {
	python selftest.py || die "selftest.py failed"
}

src_install() {
	distutils_src_install
	dodoc CHANGES
	dohtml docs/*
}
