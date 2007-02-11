# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/phpdocs/phpdocs-0.26.ebuild,v 1.14 2006/08/16 00:35:29 squinky86 Exp $

EAPI="prefix"

inherit vim-plugin

DESCRIPTION="vim plugin: PHPDoc Support in VIM"
HOMEPAGE="http://www.vim.org/scripts/script.php?script_id=520"
LICENSE="vim"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""
DEPEND="${DEPEND} >=sys-apps/sed-4"
VIM_PLUGIN_HELPURI="http://www.vim.org/scripts/script.php?script_id=520"

src_unpack() {
	unpack ${A}
	sed -i 's/\r$//' ${S}/plugin/phpdoc.vim || die "sed failed"
}
