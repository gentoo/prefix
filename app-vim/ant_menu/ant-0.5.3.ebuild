# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/ant/ant-0.5.3.ebuild,v 1.12 2006/10/05 14:35:40 gustavoz Exp $

EAPI="prefix"

inherit vim-plugin

DESCRIPTION="vim plugin: Java ant build system integration"
HOMEPAGE="http://www.vim.org/scripts/script.php?script_id=155"
LICENSE="LGPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
RDEPEND="dev-java/ant"

VIM_PLUGIN_HELPURI="http://www.vim.org/scripts/script.php?script_id=155"
