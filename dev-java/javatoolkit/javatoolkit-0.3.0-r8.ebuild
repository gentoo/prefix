# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/javatoolkit/javatoolkit-0.3.0-r8.ebuild,v 1.1 2012/07/31 20:43:10 sera Exp $

EAPI="4"

PYTHON_COMPAT="jython2_5 python2_5 python2_6 python2_7"

inherit eutils multilib python-distutils-ng prefix

DESCRIPTION="Collection of Gentoo-specific tools for Java"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

# PYTHON_USE_WITH="xml(+)" not yet available. #426768
COMMON_DEP="
	python_targets_jython2_5? ( >=dev-java/jython-2.5.2-r1:2.5 )
	python_targets_python2_5? ( dev-lang/python:2.5[xml] )
	python_targets_python2_6? ( dev-lang/python:2.6[xml] )
	python_targets_python2_7? ( dev-lang/python:2.7[xml] )"
RDEPEND="${COMMON_DEP}"
DEPEND="${COMMON_DEP}"

python_prepare_all() {
	epatch "${FILESDIR}/${P}-python2.6.patch"
	epatch "${FILESDIR}/${P}-no-pyxml.patch"

	epatch "${FILESDIR}/0.3.0-prefix.patch"
	eprefixify src/py/buildparser src/py/findclass setup.py

	# Portage wont like quotes around ${EPREFIX} #429092
	# can't pass --install-scripts to setup.py in python-distutils-ng-src_install
	cat > setup.cfg <<- EOF
		[install]
		install-scripts = ${EPREFIX}/usr/$(get_libdir)/${PN}/bin
	EOF
}
