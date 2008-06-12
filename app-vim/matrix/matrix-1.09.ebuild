# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/matrix/matrix-1.09.ebuild,v 1.2 2008/03/24 17:10:34 coldwind Exp $

EAPI="prefix"

inherit vim-plugin

DESCRIPTION="vim plugin: Screensaver inspired by the Matrix"
HOMEPAGE="http://www.vim.org/scripts/script.php?script_id=1189"
LICENSE="as-is"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

VIM_PLUGIN_HELPTEXT=\
"This plugin provides the :Matrix command. To exit the screensaver,
press a key."
