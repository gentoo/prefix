# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/emacs-updater/emacs-updater-1.4.ebuild,v 1.1 2009/04/14 11:45:26 ulm Exp $

DESCRIPTION="Rebuild Emacs packages"
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/emacs/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND="!<=app-admin/eselect-emacs-1.5
	>=app-portage/portage-utils-0.1.28
	virtual/emacs"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e '1c\#!/usr/bin/env bash' \
		-e "s:^\(EMACS\|SITELISP\)=:&${EPREFIX}:" \
		emacs-updater || die
}

src_install() {
	dosbin emacs-updater || die "dosbin failed"
	doman emacs-updater.8 || die "doman failed"
}
