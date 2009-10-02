# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pastescript/pastescript-1.7.3.ebuild,v 1.2 2009/10/01 02:33:40 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

MY_PN="PasteScript"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A pluggable command-line frontend, including commands to setup package file layouts"
HOMEPAGE="http://pythonpaste.org/script/"
SRC_URI="http://cheeseshop.python.org/packages/source/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc"
#IUSE="doc test"

RDEPEND="dev-python/paste
	dev-python/pastedeploy
	dev-python/cheetah"
DEPEND="${RDEPEND}
	dev-python/setuptools
	doc? ( dev-python/buildutils dev-python/pygments dev-python/pudge )"
#	test? ( dev-python/nose )
RESTRICT_PYTHON_ABIS="3.*"

# Tests are broken.
RESTRICT="test"

S="${WORKDIR}/${MY_P}"
PYTHON_MODNAME="paste/script"

src_compile() {
	distutils_src_compile
	if use doc; then
		einfo "Generating docs as requested..."
		PYTHONPATH=. "${python}" setup.py pudge || die "generating docs failed"
	fi
}

src_test() {
	testing() {
		PYTHONPATH="build-${PYTHON_ABI}/lib" nosetests-${PYTHON_ABI}
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install
	use doc && dohtml -r docs/html/*
}
