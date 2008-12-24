# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/genindent/genindent-1.0.ebuild,v 1.13 2006/12/07 02:10:38 flameeyes Exp $

EAPI="prefix"

inherit vim-plugin

DESCRIPTION="vim plugin: library for simplifying indent files"
HOMEPAGE="http://www.vim.org/scripts/script.php?script_id=678"
LICENSE="as-is"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

VIM_PLUGIN_HELPTEXT=\
"This plugin provides library functions and is not intended to be used
directly by the user."
