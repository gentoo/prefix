# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/vim-core/vim-core-6.4.ebuild,v 1.10 2005/11/20 00:12:03 hardave Exp $

EAPI="prefix"

inherit vim

VIM_VERSION="6.4"
# VIM_ORG_PATCHES="vim-${PV}-patches.tar.bz2"
# VIM_RUNTIME_SNAP="vim-runtime-20050809.tar.bz2"
# VIM_NETRW_SNAP="vim-6.3.084-r2-netrw.tar.bz2"
VIM_GENTOO_PATCHES="vim-${PV}-gentoo-patches.tar.bz2"
VIMRC_FILE_SUFFIX="-r2"

SRC_URI="${SRC_URI}
	ftp://ftp.vim.org/pub/vim/unix/vim-${VIM_VERSION}.tar.bz2
	nls? ( ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-lang.tar.gz )
	mirror://gentoo/${VIM_GENTOO_PATCHES}"
# 	mirror://gentoo/${VIM_RUNTIME_SNAP}
#	mirror://gentoo/${VIM_NETRW_SNAP}
#	mirror://gentoo/${VIM_ORG_PATCHES}"

S=${WORKDIR}/vim${VIM_VERSION/.}
DESCRIPTION="vim and gvim shared files"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="nls"
PDEPEND="!livecd? ( >=app-vim/gentoo-syntax-20050515 )"
