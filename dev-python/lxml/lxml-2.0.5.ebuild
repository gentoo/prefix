# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/lxml/lxml-2.0.5.ebuild,v 1.4 2008/07/13 22:07:53 josejx Exp $

NEED_PYTHON="2.3"

inherit distutils eutils multilib

DESCRIPTION="A Pythonic binding for the libxml2 and libxslt libraries"
HOMEPAGE="http://codespeak.net/lxml/"
SRC_URI="http://codespeak.net/lxml/${P}.tgz"
LICENSE="BSD ElementTree GPL-2 PSF-2.4"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="doc examples"

RDEPEND=">=dev-libs/libxml2-2.6.20
		>=dev-libs/libxslt-1.1.15"
DEPEND="${RDEPEND}
	>=dev-python/cython-0.9.6.10
	>=dev-python/setuptools-0.6_rc5"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Use cython instead of own bundled version of pyrex
	epatch "${FILESDIR}/${PN}-2.0.3-no-fake-pyrex.patch"
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml doc/html/*
		dodoc *.txt
		docinto doc
		dodoc doc/*.txt
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r samples/*
	fi
}

src_test() {
	distutils_python_version
	python setup.py build_ext -i || die "building extensions for test use failed"
	einfo "Running test"
	"${python}" test.py || die "tests failed"
	export PYTHONPATH="${PYTHONPATH}:${S}/src"
	einfo "Running selftest"
	"${python}" selftest.py || die "selftest failed"
	einfo "Running selftest2"
	"${python}" selftest2.py || die "selftest2 failed"
}
