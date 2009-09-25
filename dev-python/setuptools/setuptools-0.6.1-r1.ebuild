# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/setuptools/setuptools-0.6.1-r1.ebuild,v 1.1 2009/09/13 20:19:41 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils

DESCRIPTION="A collection of enhancements to the Python distutils including easy install"
HOMEPAGE="http://pypi.python.org/pypi/distribute"
SRC_URI="http://pypi.python.org/packages/source/d/distribute/distribute-${PV}.tar.gz"

LICENSE="PSF-2.2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""
RESTRICT_PYTHON_ABIS="3.*"

S="${WORKDIR}/distribute-${PV}"

DOCS="README.txt docs/easy_install.txt docs/pkg_resources.txt docs/setuptools.txt"

pkg_setup() {
	if has_version "=${CATEGORY}/${PN}-0.6.1"; then
		rm -fr "${EROOT}"usr/lib*/python*/site-packages/{,._cfg????_}setuptools-0.6c9-*egg-info
	fi
}

src_prepare() {
	distutils_src_prepare

	epatch "${FILESDIR}/${PN}-0.6_rc7-noexe.patch"

	# Remove tests that access the network (bugs #198312, #191117)
	rm setuptools/tests/test_packageindex.py

	sed -e "s/additional_tests/_&/" -i setuptools/tests/__init__.py || die "sed setuptools/tests/__init__.py failed"
	epatch "${FILESDIR}/distribute-${PV}-provide_setuptools.patch"
	epatch "${FILESDIR}/distribute-${PV}-USER_SITE.patch"

	sed -e "s/0\.6c9/0.6.1/" -i distribute_setup.py docs/{easy_install.txt,pkg_resources.txt,setuptools.txt} || die "Fixing of versions failed"
}

src_test() {
	tests() {
		PYTHONPATH="." "$(PYTHON)" setup.py test
	}
	python_execute_function tests
}
