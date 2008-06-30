# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/nerdcommenter/nerdcommenter-2.1.11.ebuild,v 1.1 2008/03/21 07:37:06 hawking Exp $

EAPI="prefix"

VIM_PLUGIN_VIM_VERSION=7.0
inherit vim-plugin

DESCRIPTION="vim plugin: easy commenting of code for many filetypes."
HOMEPAGE="http://www.vim.org/scripts/script.php?script_id=1218"
LICENSE="public-domain"
KEYWORDS="~x86-linux ~x86-macos ~sparc64-solaris"
IUSE=""

VIM_PLUGIN_HELPFILES="NERD_commenter"
