# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/elib/elib-1.0.ebuild,v 1.15 2008/01/25 12:10:09 opfer Exp $

EAPI="prefix"

inherit elisp

DESCRIPTION="The Emacs Lisp Library"
HOMEPAGE="http://jdee.sourceforge.net"
SRC_URI="http://jdee.sunsite.dk/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

SITEFILE=50elib-gentoo.el

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i 's:--infodir:--info-dir:g' Makefile
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	dodir "${SITELISP}"
	dodir /usr/share/info
	emake prefix="${ED}/usr" infodir="${ED}/usr/share/info" install || die "emake install failed"

	elisp-site-file-install "${FILESDIR}/${SITEFILE}"

	dodoc ChangeLog INSTALL NEWS README RELEASING TODO
}
