# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/eselect-syntax/eselect-syntax-20070506.ebuild,v 1.11 2007/08/25 11:45:24 vapier Exp $

EAPI="prefix"

inherit eutils vim-plugin

DESCRIPTION="vim plugin: Eselect syntax highlighting, filetype and indent settings"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="vim"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

DEPEND="!<app-vim/gentoo-syntax-20070506"

VIM_PLUGIN_HELPFILES="${PN}"
VIM_PLUGIN_MESSAGES="filetype"
