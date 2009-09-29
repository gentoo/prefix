# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/lxml/lxml-2.2.2.ebuild,v 1.6 2009/09/27 18:49:33 nixnut Exp $

EAPI="2"

NEED_PYTHON="2.3"
SUPPORT_PYTHON_ABIS="1"

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

RESTRICT_PYTHON_ABIS="3*"

pkg_setup() {
	# Tests fail with some optimizations.
	replace-flags -O[2-9s]* -O1
}

src_prepare() {
	# Use Cython instead of own bundled version of Pyrex.
	epatch "${FILESDIR}/${PN}-2.0.3-no-fake-pyrex.patch"
}

src_compile() {
	local myconf
	use threads || myconf+=" --without-threading"
	distutils_src_compile ${myconf}
}

src_test() {
	testing() {
		local module
		for module in lxml/etree lxml/objectify; do
			ln -fs "../../$(ls -d build-${PYTHON_ABI}/lib.*)/${module}.so" "src/${module}.so" || die "ln -fs src/${module} failed"
		done

		einfo "Running test"
		PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" test.py || die "test.py failed with Python ${PYTHON_ABI}"
		einfo "Running selftest"
		PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" selftest.py || die "selftest.py failed with Python ${PYTHON_ABI}"
		einfo "Running selftest2"
		PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" selftest2.py || die "selftest2.py failed with Python ${PYTHON_ABI}"
	}
	python_execute_function testing
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
