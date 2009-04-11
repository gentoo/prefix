# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/pybugz/pybugz-0.7.4_rc1.ebuild,v 1.1 2009/03/28 22:17:19 williamh Exp $

EAPI=2

inherit distutils eutils prefix

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
		RDEPEND="zsh-completion? ( app-shells/zsh )"

src_install() {
	distutils_src_install

	if use zsh-completion ; then
		insinto /usr/share/zsh/site-functions
		newins contrib/zsh-completion zsh_completion _pybugz
	fi
}
