# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/buildutils/buildutils-0.3.ebuild,v 1.2 2009/10/01 23:00:10 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils

DESCRIPTION="Extensions for developing Python libraries and applications."
HOMEPAGE="http://buildutils.lesscode.org http://pypi.python.org/pypi/buildutils"
SRC_URI="http://pypi.python.org/packages/source/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc"

DEPEND="dev-python/setuptools
	doc? ( dev-python/pudge )"
RDEPEND=""
RESTRICT_PYTHON_ABIS="3.*"

src_prepare() {
	distutils_src_prepare

	# pudge command is disabled by default, enable it.
	epatch "${FILESDIR}/${P}-pudge_addcommand.patch"
}

src_compile() {
	distutils_src_compile
	if use doc; then
		einfo "Generation of documentation"
		"${python}" setup.py pudge || die "Generation of documentation failed"
	fi
}

src_install() {
	distutils_src_install
	use doc && dohtml -r doc/html/*
}
