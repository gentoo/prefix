# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/semi/semi-1.14.6.ebuild,v 1.16 2007/10/16 06:30:21 opfer Exp $

EAPI="prefix"

inherit elisp eutils

DESCRIPTION="A library to provide MIME feature for GNU Emacs"
HOMEPAGE="http://www.kanji.zinbun.kyoto-u.ac.jp/~tomo/elisp/SEMI/"
SRC_URI="http://kanji.zinbun.kyoto-u.ac.jp/~tomo/lemi/dist/semi/semi-1.14-for-flim-1.14/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND=">=app-emacs/apel-10.6
	virtual/flim"
SITEFILE=65${PN}-gentoo.el

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-info.patch"
}

src_compile() {
	emake PREFIX="${ED}"/usr \
		LISPDIR="${ED}/${SITELISP}" \
		VERSION_SPECIFIC_LISPDIR="${ED}/${SITELISP}" || die "emake failed"

	emacs -batch -q --no-site-file -l "${FILESDIR}/comp.el" \
		|| die "compile info failed"
}

src_install() {
	emake PREFIX="${ED}/usr" \
		LISPDIR="${ED}/${SITELISP}" \
		VERSION_SPECIFIC_LISPDIR="${ED}/${SITELISP}" install || die "emake install failed"

	elisp-site-file-install "${FILESDIR}/${SITEFILE}"

	dodoc README* ChangeLog VERSION NEWS
	doinfo *.info
}
