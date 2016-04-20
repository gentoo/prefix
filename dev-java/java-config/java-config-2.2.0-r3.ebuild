# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

# jython depends on java-config, so don't add it or things will break
PYTHON_COMPAT=( python{2_7,3_3,3_4,3_5} )

inherit distutils-r1 eutils

DESCRIPTION="Java environment configuration query tool"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Java"
SRC_URI="https://dev.gentoo.org/~sera/distfiles/${P}.tar.bz2"

SLOT="2"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="test"

DEPEND="test? ( sys-apps/portage[${PYTHON_USEDEP}] )"

# baselayout-java is added as a dep till it can be added to eclass.
RDEPEND="
	!dev-java/java-config-wrapper
	sys-apps/baselayout-java
	sys-apps/portage[${PYTHON_USEDEP}]"

python_prepare_all() {
	distutils-r1_python_prepare_all
	epatch "${FILESDIR}/${P}-prefix.patch"
}

python_install_all() {
	distutils-r1_python_install_all

	# This replaces the file installed by java-config-wrapper.
	dosym java-config-2 /usr/bin/java-config
}

python_test() {
	esetup.py test
}
