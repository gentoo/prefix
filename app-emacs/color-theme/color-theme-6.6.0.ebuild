# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/color-theme/color-theme-6.6.0.ebuild,v 1.9 2007/09/08 10:18:50 nixnut Exp $

EAPI="prefix"

inherit elisp

DESCRIPTION="Install color themes (includes many themes and allows you to share your own with the world)"
HOMEPAGE="http://www.emacswiki.org/cgi-bin/wiki.pl?ColorTheme"
SRC_URI="http://download.gna.org/color-theme/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SITEFILE="51${PN}-gentoo.el"

src_unpack() {
	unpack ${A}
	rm "${S}"/*.elc "${S}"/color-theme-autoloads*
}

src_install() {
	elisp_src_install
	insinto /usr/share/emacs/site-lisp/color-theme/themes
	doins themes/*
}
