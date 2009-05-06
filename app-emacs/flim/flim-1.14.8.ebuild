# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/flim/flim-1.14.8.ebuild,v 1.14 2009/05/05 17:02:21 ulm Exp $

inherit elisp

DESCRIPTION="A library to provide basic features about message representation or encoding"
HOMEPAGE="http://cvs.m17n.org/elisp/FLIM/"
SRC_URI="ftp://ftp.m17n.org/pub/mule/flim/flim-1.14/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND=">=app-emacs/apel-10.3"
RDEPEND="!app-emacs/limit
	${DEPEND}"

SITEFILE=60${PN}-gentoo.el

src_compile() {
	emake PREFIX="${ED}/usr" \
		LISPDIR="${ED}/${SITELISP}" \
		VERSION_SPECIFIC_LISPDIR="${ED}/${SITELISP}" || die "emake failed"
}

src_install() {
	emake PREFIX="${ED}/usr" \
		LISPDIR="${ED}/${SITELISP}" \
		VERSION_SPECIFIC_LISPDIR="${ED}/${SITELISP}" install \
		|| die "emake install failed"

	elisp-site-file-install "${FILESDIR}/${SITEFILE}" \
		|| die "elisp-site-file-install failed"

	dodoc FLIM-API.en NEWS VERSION README* ChangeLog
}
