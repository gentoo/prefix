# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/wanderlust/wanderlust-2.15.5_pre20070921.ebuild,v 1.3 2009/05/05 17:21:00 ulm Exp $

inherit elisp

DESCRIPTION="Yet Another Message Interface on Emacsen"
HOMEPAGE="http://www.gohome.org/wl/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="bbdb ssl"

DEPEND=">=app-emacs/apel-10.6
	virtual/flim
	app-emacs/semi
	bbdb? ( app-emacs/bbdb )"
RDEPEND="!app-emacs/wanderlust-cvs
	${DEPEND}"

SITEFILE="70wl-gentoo.el"

src_compile() {
	echo '(load "'"${EPREFIX}"'/usr/share/emacs/site-lisp/site-gentoo.el")' >> WL-CFG
	use ssl && echo "(setq wl-install-utils t)" >> WL-CFG
	emake || die "emake failed"
	emake info || die "emake info failed"
}

src_install() {
	emake \
		LISPDIR="${ED}${SITELISP}" \
		PIXMAPDIR="${ED}/usr/share/wl/icons" \
		install || die "emake install failed"

	elisp-site-file-install "${FILESDIR}/${SITEFILE}" wl \
		|| die "elisp-site-file-install failed"

	insinto /usr/share/wl/samples/ja
	doins samples/ja/*
	insinto /usr/share/wl/samples/en
	doins samples/en/*

	doinfo doc/wl-ja.info doc/wl.info
	dodoc BUGS* ChangeLog INSTALL* NEWS* README*
}
