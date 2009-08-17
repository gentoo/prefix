# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/pybugz/pybugz-0.8.0_rc3.ebuild,v 1.3 2009/08/15 23:41:44 williamh Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit bash-completion distutils

DESCRIPTION="Command line interface to (Gentoo) Bugzilla"
HOMEPAGE="http://www.liquidx.net/pybugz"
SRC_URI="http://pybugz.googlecode.com/files/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""
IUSE="zsh-completion"
DEPEND="|| ( >=dev-lang/python-2.5[readline]
	( >=dev-lang/python-2.4[readline]
		dev-python/elementtree ) )"
RDEPEND="${DEPEND}
	zsh-completion? ( app-shells/zsh )"

RESTRICT_PYTHON_ABIS="3*"

PYTHON_MODNAME="bugz"

src_install() {
	distutils_src_install

	dobashcompletion contrib/bash-completion bugz

	if use zsh-completion ; then
		insinto /usr/share/zsh/site-functions
		newins contrib/zsh-completion _pybugz
	fi
}
