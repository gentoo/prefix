# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/javatoolkit/javatoolkit-0.3.0.ebuild,v 1.1 2008/06/21 14:20:33 ali_bush Exp $

EAPI="prefix"

inherit distutils eutils multilib

DESCRIPTION="Collection of Gentoo-specific tools for Java"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

PYTHON_MODNAME="javatoolkit"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	epatch "${FILESDIR}/0.3.0-prefix.patch"
	eprefixify src/py/buildparser src/py/findclass
}

src_install() {
	distutils_src_install --install-scripts="${EPREFIX}/usr/$(get_libdir)/${PN}/bin"
}

pkg_postrm() {
	distutils_python_version
	distutils_pkg_postrm
}

pkg_postinst() {
	distutils_pkg_postinst
}
