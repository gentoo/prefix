# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/cheetah/cheetah-2.0.ebuild,v 1.1 2007/10/12 23:46:37 pythonhead Exp $

NEED_PYTHON=2.2

inherit distutils

MY_PN=Cheetah
MY_P=${MY_PN}-${PV/_}

DESCRIPTION="Python-powered template engine and code generator."
HOMEPAGE="http://www.cheetahtemplate.org/"
SRC_URI="mirror://sourceforge/cheetahtemplate/${MY_P}.tar.gz"
LICENSE="PSF-2.2"
IUSE=""
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
SLOT="0"

DEPEND="dev-python/setuptools"
RDEPEND=""

S=${WORKDIR}/${MY_P}
PYTHON_MODNAME="Cheetah"
DOCS="README CHANGES TODO"
#Wacky setup.py, must have for Python 2.4:
export CHEETAH_USE_SETUPTOOLS='true'

pkg_postinst() {
	ewarn "This release requires re-compilation of all compiled templates!"
}

src_test() {
	#We need to do the sed here because files don't exist until after src_build
	local p="$(ls -d ${S}/build/lib.* )"
	local s="$(ls -d ${S}/build/scripts*)"
	sed -i \
		-e "s:\(self\.go(\"\)\(${PN}\):\1PYTHONPATH=\'${p}\' \'${s}/\2\':" \
		src/Tests/CheetahWrapper.py || die "sed failed"

	PYTHONPATH="${p}" "${python}" src/Tests/Test.py || die "tests failed"
}
