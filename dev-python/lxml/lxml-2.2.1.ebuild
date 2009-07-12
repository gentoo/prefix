# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/lxml/lxml-2.2.1.ebuild,v 1.5 2009/07/10 12:27:20 fmccor Exp $

EAPI="2"

NEED_PYTHON="2.3"

inherit distutils flag-o-matic

DESCRIPTION="A Pythonic binding for the libxml2 and libxslt libraries"
HOMEPAGE="http://codespeak.net/lxml/"
SRC_URI="http://codespeak.net/lxml/${P}.tgz"
LICENSE="BSD ElementTree GPL-2 PSF-2.4"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="doc examples +threads"

RDEPEND=">=dev-libs/libxml2-2.7.2
		>=dev-libs/libxslt-1.1.15"
DEPEND="${RDEPEND}
	>=dev-python/cython-0.9.8
	>=dev-python/setuptools-0.6_rc5"

pkg_setup() {
	# Tests fail with some optimizations.
	replace-flags -O[2-9]* -O1
}

src_prepare() {
	# Use Cython instead of own bundled version of Pyrex.
	epatch "${FILESDIR}/${PN}-2.0.3-no-fake-pyrex.patch"
}

src_compile() {
	local myconf
	use threads || myconf+=" --without-threading"
	${python} setup.py build ${myconf} || die "compilation failed"
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
