# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/wanderlust/wanderlust-2.14.0-r3.ebuild,v 1.2 2007/04/19 14:05:32 kloeri Exp $

EAPI="prefix"

inherit elisp eutils

MY_P="wl-${PV/_/}"

IUSE="bbdb ssl"

DESCRIPTION="Yet Another Message Interface on Emacsen"
HOMEPAGE="http://www.gohome.org/wl/"
SRC_URI="ftp://ftp.gohome.org/wl/stable/${MY_P}.tar.gz
	ftp://ftp.gohome.org/wl/beta/${MY_P}.tar.gz
	http://dev.gentoo.org/~usata/distfiles/${MY_P}-20050405.diff"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"

DEPEND=">=app-emacs/apel-10.6
	virtual/flim
	virtual/semi
	bbdb? ( app-emacs/bbdb )
	!app-emacs/wanderlust-cvs"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${MY_P}.tar.gz

	cd "${S}"
	epatch "${DISTDIR}/${MY_P}-20050405.diff"
}

src_compile() {
	echo '(load "'"${EPREFIX}"'/usr/share/emacs/site-lisp/site-gentoo.el")' >> WL-CFG
	use ssl && echo "(setq wl-install-utils t)" >> WL-CFG
	make || die
	make info || die
	if use bbdb; then
		cd utils
		EMACS="emacs -L ../../elmo -L ../../wl" elisp-comp bbdb-wl.el
	fi
}

src_install() {
	make \
		LISPDIR="${ED}/usr/share/emacs/site-lisp" \
		PIXMAPDIR="${ED}/usr/share/wl/icons" \
		install || die

	elisp-install wl utils/bbdb-wl.{el,elc}
	elisp-site-file-install "${FILESDIR}/70wl-gentoo.el" || die

	dodir /usr/share/wl/samples

	insinto /usr/share/wl/samples/ja
	doins samples/ja/*
	insinto /usr/share/wl/samples/en
	doins samples/en/*

	doinfo doc/wl-ja.info doc/wl.info
	dodoc BUGS* ChangeLog INSTALL* README*
}
