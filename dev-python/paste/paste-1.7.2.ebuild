# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/paste/paste-1.7.2.ebuild,v 1.2 2009/10/01 01:55:21 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

MY_PN="Paste"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Tools for using a Web Server Gateway Interface stack"
HOMEPAGE="http://pythonpaste.org"
SRC_URI="http://cheeseshop.python.org/packages/source/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc flup openid"

RDEPEND="flup? ( dev-python/flup )
	openid? ( dev-python/python-openid )"
DEPEND="${RDEPEND}
	dev-python/setuptools
	doc? ( dev-python/pudge dev-python/buildutils )"
RESTRICT_PYTHON_ABIS="3.*"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	distutils_src_prepare

	sed -i \
		-e '/highlighter/d' \
		setup.cfg || die "sed failed"
}

src_compile() {
	distutils_src_compile
	if use doc; then
		einfo "Generation of documentation"
		PYTHONPATH=. "${python}" setup.py pudge || die "Generation of documentation failed"
	fi
}

# src_test() needs py.test but there's no release yet.

src_install() {
	distutils_src_install
	use doc && dohtml -r docs/html/*
}
