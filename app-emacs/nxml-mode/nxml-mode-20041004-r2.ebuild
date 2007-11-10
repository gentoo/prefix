# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/nxml-mode/nxml-mode-20041004-r2.ebuild,v 1.1 2007/09/09 10:00:18 ulm Exp $

EAPI="prefix"

inherit elisp eutils

DESCRIPTION="A major mode for GNU Emacs for editing XML documents."
HOMEPAGE="http://www.thaiopensource.com/nxml-mode/
http://www.emacswiki.org/cgi-bin/wiki/NxmlMode"
SRC_URI="http://thaiopensource.com/download/${P}.tar.gz
	mirror://gentoo/${PN}-20040910-xmlschema.patch.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

SITEFILE=80${PN}-gentoo.el

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-info-gentoo.patch"
	epatch "${WORKDIR}/${PN}-20040910-xmlschema.patch"
	epatch "${FILESDIR}/xsd-regexp.el.2006-01-26.patch"		# bug #188112
	epatch "${FILESDIR}/${PN}-xmlschema-xpath.patch"		# bug #188114
}

src_compile() {
	emacs -batch -l rng-auto.el -f rng-byte-compile-load \
		|| die "byte compilation failed"
	makeinfo --force nxml-mode.texi || die "makeinfo failed"
}

src_install() {
	elisp-install ${PN} *.el *.elc
	elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	cp -r "${S}/schema" "${ED}/${SITELISP}/${PN}"
	cp -r "${S}/char-name" "${ED}/${SITELISP}/${PN}"
	doinfo nxml-mode.info
	dodoc README VERSION TODO NEWS || die "dodoc failed"
}
