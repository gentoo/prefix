# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/desktop-file-utils/desktop-file-utils-0.14.ebuild,v 1.13 2007/12/22 17:27:02 dang Exp $

EAPI="prefix"

inherit eutils elisp-common

DESCRIPTION="Command line utilities to work with desktop menu entries"
HOMEPAGE="http://www.freedesktop.org/software/desktop-file-utils"
SRC_URI="http://www.freedesktop.org/software/${PN}/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~sparc-solaris ~x86"
IUSE="emacs"

RDEPEND=">=dev-libs/glib-2.12
	emacs? ( virtual/emacs )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

SITEFILE=50${PN}-gentoo.el

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e 's:misc::' Makefile.in
	# add manpages from bug 85354
	epatch "${FILESDIR}"/${PN}-0.10-man.patch
}

src_compile() {
	econf
	emake || die "emake failed."
	use emacs && elisp-compile misc/desktop-entry-mode.el
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."

	if use emacs; then
		elisp-install ${PN} misc/*.el misc/*.elc || die "elisp-install failed."
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	fi

	dodoc AUTHORS ChangeLog NEWS README
	doman man/*
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
