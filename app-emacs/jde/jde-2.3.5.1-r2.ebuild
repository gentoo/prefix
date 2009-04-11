# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/jde/jde-2.3.5.1-r2.ebuild,v 1.4 2009/04/06 20:44:59 maekke Exp $

inherit elisp eutils

DESCRIPTION="Java Development Environment for Emacs"
HOMEPAGE="http://jdee.sourceforge.net/"
SRC_URI="mirror://sourceforge/jdee/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1 Apache-1.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="app-emacs/elib
	>=app-emacs/cedet-1.0_beta3"
RDEPEND="${DEPEND}
	>=virtual/jdk-1.3"

SITEFILE="70${PN}-gentoo.el"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-fix-efc.patch"
	epatch "${FILESDIR}/${P}-import.patch"
}

src_compile() {
	cd lisp
	cat >jde-compile-script-init <<-EOF
	(load "${ESITELISP}/cedet/common/cedet")
	(add-to-list 'load-path "${S}/lisp")
	(require 'jde)
	EOF
	emacs -batch -l jde-compile-script-init -f batch-byte-compile *.el \
		|| die "batch-byte-compile failed"
}

src_install() {
	elisp-install ${PN}/lisp lisp/*.{el,elc,bnf} || die
	elisp-site-file-install "${FILESDIR}/${SITEFILE}" || die

	dobin lisp/jtags* || die "dobin failed"

	# this should be installed outside of SITELISP
	insinto ${SITELISP}/${PN}
	doins -r java || die "doins failed"

	dohtml -r doc/html/* || die "dohtml failed"
	dodoc lisp/ChangeLog lisp/ReleaseNotes.txt
}
