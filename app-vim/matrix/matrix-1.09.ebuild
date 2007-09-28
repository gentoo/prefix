# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/matrix/matrix-1.09.ebuild,v 1.1 2007/05/08 20:23:15 pioto Exp $

EAPI="prefix"

inherit vim-plugin

DESCRIPTION="vim plugin: Screensaver inspired by the Matrix"
HOMEPAGE="http://www.vim.org/scripts/script.php?script_id=1189"
LICENSE="as-is"
KEYWORDS="~amd64 ~mips ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

VIM_PLUGIN_HELPTEXT=\
"This plugin provides the :Matrix command. To exit the screensaver,
press a key."
