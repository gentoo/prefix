# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/alternate/alternate-2.15.ebuild,v 1.1 2007/01/04 02:47:53 beu Exp $

EAPI="prefix"

inherit vim-plugin eutils

DESCRIPTION="vim plugin: quickly switch between .c and .h files"
HOMEPAGE="http://www.vim.org/scripts/script.php?script_id=31"

LICENSE="as-is"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

VIM_PLUGIN_HELPTEXT=\
"This plugin provides a new :A command which will switch between a .c
file and the associated .h file. There is also :AS to split windows and
:AV to split windows vertiically."

src_unpack() {
	unpack ${A}
	cd ${S}
	# fix switching between .cc and .hh files, thanks ciaranm
	epatch ${FILESDIR}/${PN}-2.12-hh-cc-alternation.patch
}
