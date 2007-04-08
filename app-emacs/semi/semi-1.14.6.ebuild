# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/semi/semi-1.14.6.ebuild,v 1.13 2007/03/30 20:12:31 grobian Exp $

EAPI="prefix"

inherit elisp eutils

IUSE=""

DESCRIPTION="a library to provide MIME feature for GNU Emacs -- SEMI"
HOMEPAGE="http://www.kanji.zinbun.kyoto-u.ac.jp/~tomo/elisp/SEMI/"
SRC_URI="http://kanji.zinbun.kyoto-u.ac.jp/~tomo/lemi/dist/semi/semi-1.14-for-flim-1.14/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"

DEPEND=">=app-emacs/apel-10.6
	virtual/flim
	!virtual/semi"

PROVIDE="virtual/semi"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-info.patch"
}

src_compile() {
	make PREFIX="${ED}"/usr \
		LISPDIR="${D}/${SITELISP}" \
		VERSION_SPECIFIC_LISPDIR="${D}/${SITELISP}" || die

	emacs -batch -q --no-site-file -l "${FILESDIR}/comp.el" \
		|| die "compile info failed"
}

src_install() {
	make PREFIX="${ED}/usr" \
		LISPDIR="${D}/${SITELISP}" \
		VERSION_SPECIFIC_LISPDIR="${D}/${SITELISP}" install || die

	elisp-site-file-install "${FILESDIR}/65semi-gentoo.el"

	dodoc README* ChangeLog VERSION NEWS
	doinfo *.info
}
