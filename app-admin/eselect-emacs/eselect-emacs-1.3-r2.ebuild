# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-emacs/eselect-emacs-1.3-r2.ebuild,v 1.9 2008/01/22 08:14:58 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Manages Emacs versions"
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/emacs/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-fbsd ~ia64-hpux ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=">=app-admin/eselect-1.0.10"
# Now this should really be in RDEPEND, but it would result in blockers when
# updating from <=eselect-emacs-1.3. Leave it as PDEPEND for the time being.
PDEPEND="app-admin/eselect-ctags"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.2-prefix.patch
	cp "${FILESDIR}"/emacs-updater .
	epatch "${FILESDIR}"/emacs-updater-prefix.patch
	eprefixify *.eselect emacs-updater
}

src_install() {
	insinto /usr/share/eselect/modules
	doins emacs.eselect || die "doins failed"
	doman emacs.eselect.5 || die "doman failed"
	dodoc ChangeLog || die "dodoc failed"
	dosbin emacs-updater || die "dosbin failed"
}
