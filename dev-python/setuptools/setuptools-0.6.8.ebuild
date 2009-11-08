# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/setuptools/setuptools-0.6.8.ebuild,v 1.3 2009/11/06 17:47:32 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils

DESCRIPTION="Distribute (fork of Setuptools) is a collection of extensions to Distutils"
HOMEPAGE="http://pypi.python.org/pypi/distribute"
SRC_URI="http://pypi.python.org/packages/source/d/distribute/distribute-${PV}.tar.gz"

LICENSE="PSF-2.2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/distribute-${PV}"

DOCS="README.txt docs/easy_install.txt docs/pkg_resources.txt docs/setuptools.txt"

src_prepare() {
	distutils_src_prepare

	epatch "${FILESDIR}/${PN}-0.6_rc7-noexe.patch"

	# Remove tests that access the network (bugs #198312, #191117)
	rm setuptools/tests/test_packageindex.py

	# https://bitbucket.org/tarek/distribute/issue/87/
	sed -e 's:if copied and outf.endswith(".py"):& and outf != "build/src/distribute_setup.py":' -i setup.py || die "sed setup.py failed"
}

src_test() {
	tests() {
		PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" setup.py build -b "build-${PYTHON_ABI}" test
	}
	python_execute_function tests
}

src_install() {
	DONT_PATCH_SETUPTOOLS="1" distutils_src_install
}

pkg_preinst() {
	# Delete unneeded files which cause problems. These files were created by some older, broken versions.
	if has_version "<dev-python/setuptools-0.6.3-r2"; then
		rm -fr "${EROOT}"usr/lib*/python*/site-packages/{,._cfg????_}setuptools-*egg-info* || die "Deletion of broken files failed"
	fi
}
