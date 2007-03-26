# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/preview-latex/preview-latex-0.9.1.ebuild,v 1.3 2007/01/19 15:03:31 masterdriverz Exp $

EAPI="prefix"

inherit latex-package elisp-common

DESCRIPTION="Renders embed latex environments such as math or figures in realtime"
HOMEPAGE="http://preview-latex.sourceforge.net/"
SRC_URI="mirror://sourceforge/preview-latex/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="emacs xemacs"

# if you don't have either emacs or xemacs, defaults to emacs. bug #54183
DEPEND="emacs? ( virtual/emacs
		>=app-emacs/auctex-11.55 )
	xemacs? ( virtual/xemacs
		>=app-xemacs/auctex-1.32
		app-xemacs/fsf-compat )
	!xemacs? ( virtual/emacs
		>=app-emacs/auctex-11.55 )
	virtual/ghostscript
	virtual/tetex"

src_unpack() {
	unpack ${A}
	cp -pPR ${P}/* ${T}
}

src_compile() {
	local myconf
	export LC_ALL=en_US.ISO8859-1

	if use emacs || ! use xemacs ; then
		econf --with-emacs \
			--with-lispdir=${ED}/usr/share/emacs/site-lisp/${PN} \
			|| die
		emake -j1 || die "make ${PN} for emacs failed"
	fi
	if use xemacs; then
		cd ${T}
		econf --with-xemacs \
			--with-packagedir=${ED}/usr/lib/xemacs/site-packages \
			|| die
		emake -j1 || die "make ${PN} for xemacs failed"
	fi
}

src_install() {

	if use emacs || ! use xemacs ; then
		# hack.- we cant call texhash within the make install because of
		# sandbox violations. doing it later by hand
		einstall texmfdir=${ED}${TEXMF} TEXHASH=/bin/true || die
		elisp-site-file-install ${FILESDIR}/60preview-latex-gentoo.el
	fi
	if use xemacs; then
		cd ${T}
		einstall texmfdir=${ED}${TEXMF} TEXHASH="${EPREFIX}"/bin/true || die
	fi

	dodoc ChangeLog FAQ INSTALL PROBLEMS README RELEASE TODO doc/preview-latex.dvi
}

pkg_postinst() {
	latex-package_pkg_postinst
	use emacs && elisp-site-regen
}

pkg_postrm() {
	latex-package_pkg_postrm
	use emacs && elisp-site-regen
}
