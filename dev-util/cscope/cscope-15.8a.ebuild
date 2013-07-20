# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cscope/cscope-15.8a.ebuild,v 1.8 2012/09/29 18:45:43 armin76 Exp $

EAPI=4

inherit autotools elisp-common eutils

DESCRIPTION="Interactively examine a C program"
HOMEPAGE="http://cscope.sourceforge.net/"
SRC_URI="mirror://sourceforge/cscope/${P}.tar.gz"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="emacs"

RDEPEND=">=sys-libs/ncurses-5.2
	emacs? ( virtual/emacs )"
DEPEND="${RDEPEND}
	sys-devel/flex
	virtual/yacc"

SITEFILE="50${PN}-gentoo.el"

src_prepare() {
	epatch "${FILESDIR}/${PN}-15.7a-ocs-sysdir.patch" #269305
	eautoreconf		  # prevent maintainer mode later on

	epatch "${FILESDIR}"/${PN}-15.6-darwin.patch
	epatch "${FILESDIR}"/${PN}-15.6-r3-interix.patch
}

src_configure() {
	econf --with-ncurses="${EPREFIX}"/usr
}

src_compile() {
	emake
	if use emacs; then
		cd "${S}"/contrib/xcscope || die
		elisp-compile *.el || die
	fi
}

src_install() {
	default

	if use emacs; then
		cd "${S}"/contrib/xcscope || die
		elisp-install ${PN} *.el *.elc || die
		elisp-site-file-install "${FILESDIR}/${SITEFILE}" || die
		dobin cscope-indexer
	fi

	cd "${S}"/contrib/webcscope || die
	docinto webcscope
	dodoc INSTALL TODO cgi-lib.pl cscope hilite.c
	docinto webcscope/icons
	dodoc icons/*.gif
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
