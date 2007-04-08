# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/phpdocs/phpdocs-0.26.ebuild,v 1.15 2007/02/11 14:05:38 grobian Exp $

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
