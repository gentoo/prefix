# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/scons/scons-1.2.0_p20091224.ebuild,v 1.3 2010/02/08 08:55:09 pva Exp $

EAPI=2

inherit eutils distutils

MY_PV=${PV/_p/.d}

DESCRIPTION="Extensible Python-based build utility"
SRC_URI="mirror://sourceforge/${PN}/${PN}-${MY_PV}.tar.gz
	doc? ( http://www.scons.org/doc/${MY_PV}/PDF/${PN}-user.pdf -> ${P}-user.pdf
		   http://www.scons.org/doc/${MY_PV}/HTML/${PN}-user.html -> ${P}-user.html )"

HOMEPAGE="http://www.scons.org/"

SLOT="0"
LICENSE="MIT"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc"
DEPEND=">=dev-lang/python-2.5[threads]"
RDEPEND=${DEPEND}
DOCS="RELEASE.txt CHANGES.txt"

S=${WORKDIR}/${PN}-${MY_PV}

src_prepare() {
	epatch "${FILESDIR}"/scons-1.2.0-popen.patch
}

src_install () {
	distutils_src_install
	# move man pages from /usr/man to /usr/share/man
	dodir /usr/share
	mv "${ED}"/usr/man "${ED}"/usr/share
	if use doc; then
		insinto /usr/share/doc/${PF}
		doins "${DISTDIR}"/${P}-user.{pdf,html}
	fi
}

pkg_postinst() {
	python_mod_optimize /usr/$(get_libdir)/${PN}-${MY_PV}
}

pkg_postrm() {
	python_mod_cleanup /usr/$(get_libdir)/${PN}-${MY_PV}
}
