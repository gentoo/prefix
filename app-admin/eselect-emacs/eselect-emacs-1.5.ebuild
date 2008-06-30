# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-emacs/eselect-emacs-1.5.ebuild,v 1.7 2008/06/28 14:19:03 armin76 Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Manages Emacs versions"
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/emacs/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=">=app-admin/eselect-1.0.10
	~app-admin/eselect-ctags-${PV}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.4-prefix.patch
	cp "${FILESDIR}"/emacs-updater .
	eprefixify *.eselect emacs-updater
}

src_install() {
	insinto /usr/share/eselect/modules
	doins {emacs,etags}.eselect || die "doins failed"
	doman {emacs,etags}.eselect.5 || die "doman failed"
	dodoc ChangeLog || die "dodoc failed"
	dosbin emacs-updater || die "dosbin failed"
}
