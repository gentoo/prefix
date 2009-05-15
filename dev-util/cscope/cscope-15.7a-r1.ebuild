# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cscope/cscope-15.7a-r1.ebuild,v 1.2 2009/05/11 21:03:59 ulm Exp $

inherit elisp-common eutils

DESCRIPTION="Interactively examine a C program"
HOMEPAGE="http://cscope.sourceforge.net/"
SRC_URI="mirror://sourceforge/cscope/${P}.tar.bz2"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="emacs"

RDEPEND=">=sys-libs/ncurses-5.2
	emacs? ( virtual/emacs )"
DEPEND="${RDEPEND}
	sys-devel/flex
	sys-devel/bison
	>=sys-devel/autoconf-2.60"

SITEFILE="50${PN}-gentoo.el"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-15.6-darwin.patch
	epatch "${FILESDIR}"/${PN}-15.6-r3-interix.patch
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-ocs-sysdir.patch" #269305
}

src_compile() {
	STRIP="no"

	econf --with-ncurses="${EPREFIX}"/usr || die "econf failed"
	make clean || die "make clean failed"
	emake || die "emake failed"

	if use emacs ; then
		cd "${S}"/contrib/xcscope || die
		elisp-compile *.el || die
	fi
}

src_install() {
	einstall || die "einstall failed"
	dodoc AUTHORS ChangeLog NEWS README* TODO || die "dodoc failed"

	if use emacs ; then
		cd "${S}"/contrib/xcscope || die
		elisp-install ${PN} *.el *.elc || die
		elisp-site-file-install "${FILESDIR}/${SITEFILE}" || die
		dobin cscope-indexer || die "dobin failed"
	fi

	cd "${S}"/contrib/webcscope || die
	docinto webcscope
	dodoc INSTALL TODO cgi-lib.pl cscope hilite.c || die "dodoc failed"
	insinto /usr/share/doc/${PF}/webcscope/icons; doins icons/*.gif
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
