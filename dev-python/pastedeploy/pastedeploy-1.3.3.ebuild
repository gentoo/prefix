# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pastedeploy/pastedeploy-1.3.3.ebuild,v 1.2 2009/07/04 16:34:00 arfrever Exp $

NEED_PYTHON=2.4

inherit eutils distutils multilib

KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"

MY_PN=PasteDeploy
MY_P=${MY_PN}-${PV}

DESCRIPTION="Load, configure, and compose WSGI applications and servers"
HOMEPAGE="http://pythonpaste.org/deploy/"
SRC_URI="http://cheeseshop.python.org/packages/source/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"
LICENSE="MIT"
SLOT="0"
IUSE="doc test"

RDEPEND=""
DEPEND="dev-python/setuptools
	doc? ( dev-python/buildutils dev-python/pygments dev-python/pudge )
	test? ( dev-python/nose dev-python/py )"

S=${WORKDIR}/${MY_P}

PYTHON_MODNAME="paste/deploy"
RESTRICT="test"

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
	distutils_python_version

	# Tests can't import paste from site-packages
	# So we copy pastedeploy and paste under T.
	# FIXME This doesn't work. Couldn't figure out why -hawking.
	cp -pPR build/lib/paste "${T}" || die "couldn't copy pastedeploy."
	cp -pPR "${EPREFIX}"/usr/$(get_libdir)/python${PYVER}/site-packages/paste/* \
		"${T}"/paste/ || die "couldn't copy paste."

	PYTHONPATH="${T}" "${python}" setup.py nosetests || die "tests failed"
}
