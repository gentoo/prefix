# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/jde/jde-2.3.5.1.ebuild,v 1.8 2009/03/02 21:40:12 ulm Exp $

EAPI="prefix"

inherit elisp

DESCRIPTION="Java Development Environment for Emacs"
HOMEPAGE="http://jdee.sourceforge.net/"
SRC_URI="mirror://sourceforge/jdee/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="app-emacs/elib
	>=app-emacs/cedet-1.0_beta3"
RDEPEND="${DEPEND}
	>=virtual/jdk-1.3"

SITEFILE="70${PN}-gentoo.el"

src_compile() {
	cd "${S}"/lisp
	cat >jde-compile-script-init <<-EOF
	(load "${ESITELISP}/cedet/common/cedet")
	(add-to-list 'load-path "$PWD")
	EOF
	emacs -batch -l jde-compile-script-init -f batch-byte-compile *.el || die
}

src_install() {
	dodir ${SITELISP}/${PN}
	cp -r java "${ED}"/${SITELISP}/${PN}/ || die
	dodir /usr/share/doc/${P}
	cp -r doc/* "${ED}"/usr/share/doc/${P}/ || die
	cd "${S}"/lisp
	elisp-install ${PN}/lisp *.el *.elc *.bnf || die
	elisp-site-file-install "${FILESDIR}/${SITEFILE}" || die
	dodoc ChangeLog ReleaseNotes.txt
	find "${ED}" -type f -print0 | xargs -0 chmod 644
	exeinto /usr/bin
	doexe jtags* || die
}
