# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/colorschemes/colorschemes-20070707.ebuild,v 1.5 2008/03/09 14:42:23 armin76 Exp $

EAPI="prefix"

inherit vim-plugin eutils

DESCRIPTION="vim plugin: a collection of color schemes from vim.org"
HOMEPAGE="http://www.vim.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="vim GPL-2 public-domain as-is"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

VIM_PLUGIN_HELPTEXT=\
"This plugin provides a collection of color schemes for vim. To switch
color schemes, use :colorscheme schemename (tab completion is available
for scheme names). To automatically set a scheme at startup, please see
:help vimrc ."

src_unpack() {

	unpack ${A}

	cd "${S}"

	EPATCH_SOURCE="${S}/patches"
	EPATCH_SUFFIX="patch"
	EPATCH_FORCE="yes"
	epatch

	einfo "Fixing line endings"
	find . -name '*.vim' -exec sed -i -e 's,\r,\n,g' {} \;

}
