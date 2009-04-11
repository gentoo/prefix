# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/ipython/ipython-0.8.4-r1.ebuild,v 1.2 2008/08/25 08:46:32 hawking Exp $

NEED_PYTHON=2.3

inherit eutils distutils elisp-common

DESCRIPTION="An advanced interactive shell for Python."
HOMEPAGE="http://ipython.scipy.org/"
SRC_URI="http://ipython.scipy.org/dist/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc examples emacs gnuplot"

RDEPEND="gnuplot? ( dev-python/gnuplot-py )
	emacs? ( app-emacs/python-mode virtual/emacs )
	dev-python/pexpect"
DEPEND="${RDEPEND}"

PYTHON_MODNAME="IPython"
SITEFILE="62ipython-gentoo.el"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-globalpath.patch
	epatch "${FILESDIR}"/${P}-jobctrl.patch

	sed -i \
		-e '/examfiles)/d' \
		-e '/manfiles)/d' \
		-e '/manstatic)/d' \
		-e 's/^docfiles.*/docfiles=""/' \
		setup.py || die "sed failed"
}

src_compile() {
	distutils_src_compile
	if use emacs ; then
		elisp-compile doc/ipython.el || die "elisp-compile failed"
	fi
}

src_install() {
	DOCS="doc/ChangeLog"
	distutils_src_install

	cd doc
	insinto /usr/share/doc/${PF}

	if use doc; then
		doins -r *.pdf manual/* || die "doc install failed"
	fi
	if use examples ; then
		doins -r examples || die "examples install failed"
	fi
	if use emacs ; then
		elisp-install ${PN} ipython.el ipython.elc || die "elisp-install failed"
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	fi
}

pkg_postinst() {
	distutils_pkg_postinst
	use emacs && elisp-site-regen
}

pkg_postrm() {
	distutils_pkg_postrm
	use emacs && elisp-site-regen
}
