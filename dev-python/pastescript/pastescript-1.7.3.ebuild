# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pastescript/pastescript-1.7.3.ebuild,v 1.1 2009/04/26 09:53:29 patrick Exp $

NEED_PYTHON=2.4

inherit distutils

KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

MY_PN=PasteScript
MY_P=${MY_PN}-${PV}

DESCRIPTION="A pluggable command-line frontend, including commands to setup package file layouts"
HOMEPAGE="http://pythonpaste.org/script/"
SRC_URI="http://cheeseshop.python.org/packages/source/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"
LICENSE="MIT"
SLOT="0"
IUSE="doc test"

RDEPEND="dev-python/paste
	dev-python/pastedeploy
	dev-python/cheetah"
DEPEND="${RDEPEND}
	dev-python/setuptools
	doc? ( dev-python/buildutils dev-python/pygments dev-python/pudge )
	test? ( dev-python/nose )"

# The tests are currently broken, needs further investigation
RESTRICT=test

S="${WORKDIR}/${MY_P}"
PYTHON_MODNAME="paste/script"

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

src_test() {
	# Tests can't import paste from site-packages
	# so we copy them over.
	# The files that will be installed are already copied to build/lib
	# so this shouldn't generate any collisions.
	distutils_python_version
	cp -pPR /usr/$(get_libdir)/python${PYVER}/site-packages/paste/* paste/

	PYTHONPATH=. "${python}" setup.py nosetests || die "tests failed"
}
