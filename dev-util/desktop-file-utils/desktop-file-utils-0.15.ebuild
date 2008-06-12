# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/desktop-file-utils/desktop-file-utils-0.15.ebuild,v 1.8 2008/04/14 23:31:10 jer Exp $

EAPI="prefix"

inherit elisp-common

DESCRIPTION="Command line utilities to work with desktop menu entries"
HOMEPAGE="http://freedesktop.org/wiki/Software/desktop-file-utils"
SRC_URI="http://www.freedesktop.org/software/${PN}/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE="emacs"

RDEPEND=">=dev-libs/glib-2.12
	emacs? ( virtual/emacs )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

SITEFILE=50${PN}-gentoo.el

src_unpack() {
	unpack ${A}
	sed -i -e 's:misc::' "${S}"/Makefile.in
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
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
