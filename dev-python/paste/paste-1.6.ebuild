# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/paste/paste-1.6.ebuild,v 1.2 2008/05/13 13:21:08 hawking Exp $

EAPI="prefix"

NEED_PYTHON=2.4

inherit distutils

KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

MY_PN=Paste
MY_P=${MY_PN}-${PV}

DESCRIPTION="Tools for using a Web Server Gateway Interface stack"
HOMEPAGE="http://pythonpaste.org"
SRC_URI="http://cheeseshop.python.org/packages/source/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"
LICENSE="MIT"
SLOT="0"
IUSE="doc flup openid"

RDEPEND="flup? ( dev-python/flup )
	openid? ( dev-python/python-openid )"
DEPEND="${RDEPEND}
	dev-python/setuptools
	doc? ( dev-python/pudge dev-python/buildutils )"

S=${WORKDIR}/${MY_P}

src_unpack() {
	distutils_src_unpack

	sed -i \
		-e '/highlighter/d' \
		setup.cfg || die "sed failed"
}

src_compile() {
	distutils_src_compile
	if use doc ; then
		einfo "Generating docs as requested..."
		PYTHONPATH=. "${python}" setup.py pudge || die "generating docs failed"
	fi
}

src_install() {
	distutils_src_install
	use doc && dohtml -r docs/html/*
}

# src_test() needs py.test but there's no release yet
