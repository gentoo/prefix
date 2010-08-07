# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/scons/scons-1.3.0_p20100501.ebuild,v 1.6 2010/07/18 18:00:16 ssuominen Exp $

EAPI="3"
PYTHON_DEPEND="2"
PYTHON_USE_WITH="threads"

inherit distutils eutils

MY_PV="${PV/_p/.d}"
DOC_PV="${PV/_p*/}"

DESCRIPTION="Extensible Python-based build utility"
HOMEPAGE="http://www.scons.org/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-${MY_PV}.tar.gz
	doc? (
		http://www.scons.org/doc/${DOC_PV}/PDF/${PN}-user.pdf -> ${P}-user.pdf
		http://www.scons.org/doc/${DOC_PV}/HTML/${PN}-user.html -> ${P}-user.html
	)"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc"

DEPEND=""
RDEPEND=""

DOCS="CHANGES.txt RELEASE.txt"

S="${WORKDIR}/${PN}-${MY_PV}"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/scons-1.2.0-popen.patch"
}

src_install () {
	distutils_src_install
	python_convert_shebangs -r 2 "${ED}"

	# Move man pages from /usr/man to /usr/share/man
	dodir /usr/share
	mv "${ED}usr/man" "${ED}usr/share"

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
