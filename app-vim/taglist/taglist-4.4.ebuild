# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/taglist/taglist-4.4.ebuild,v 1.2 2007/11/29 03:47:35 hawking Exp $

EAPI="prefix"

inherit vim-plugin eutils

DESCRIPTION="vim plugin: ctags-based source code browser"
HOMEPAGE="http://vim-taglist.sourceforge.net/"

LICENSE="vim"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND="dev-util/ctags"

VIM_PLUGIN_HELPFILES="taglist-intro"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-3.4-ebuilds.patch
	[[ -f plugin/${PN}.vim.orig ]] && rm plugin/${PN}.vim.orig
}
