# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/jde/jde-2.3.5.1.ebuild,v 1.5 2006/08/13 08:36:06 grobian Exp $

EAPI="prefix"

inherit elisp eutils

DESCRIPTION="Java Development Environment for Emacs"
HOMEPAGE="http://jdee.sunsite.dk/"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND="virtual/emacs
	>=virtual/jdk-1.3
	app-emacs/elib
	>=app-emacs/cedet-1.0_beta3"

SITEFILE=70jde-gentoo.el

S=${WORKDIR}/${P}

src_compile() {
	cd ${S}/lisp
	cat >jde-compile-script-init <<EOF
(load "${ESITELISP}/cedet/common/cedet")
(add-to-list 'load-path "$PWD")
EOF
	emacs -batch -l jde-compile-script-init -f batch-byte-compile *.el
}

src_install() {
	dodir ${SITELISP}/${PN}
	cp -r java ${ED}/${SITELISP}/${PN}/
	dodir /usr/share/doc/${P}
	cp -r doc/* ${ED}/usr/share/doc/${P}/
	cd ${S}/lisp
	elisp-install ${PN}/lisp *.el *.elc *.bnf
	cp ${FILESDIR}/${PV}-${SITEFILE} ${S}/${SITEFILE}; elisp-site-file-install ${S}/${SITEFILE}
	dodoc ChangeLog ReleaseNotes.txt
	find ${ED} -type f -print0 |xargs -0 chmod 644
	exeinto /usr/bin
	doexe jtags*
}
