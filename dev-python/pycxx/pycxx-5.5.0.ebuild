# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycxx/pycxx-5.5.0.ebuild,v 1.1 2009/02/15 21:20:08 patrick Exp $

EAPI=2
inherit eutils distutils

DESCRIPTION="Set of facilities to extend Python with C++"
HOMEPAGE="http://cxx.sourceforge.net"
SRC_URI="mirror://sourceforge/cxx/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="doc examples"

PYTHON_MODNAME="CXX"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-5.4.2-headers-c.patch
}

src_install() {
	distutils_src_install
	if use doc; then
		dohtml Doc/{PyCXX.html,style.css} || die "dohtml failed"
	fi

	if use examples; then
		docinto examples
		dodoc Demo/* || die "dodoc failed"
	fi
}
