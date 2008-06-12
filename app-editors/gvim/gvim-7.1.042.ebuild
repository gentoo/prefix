# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/gvim/gvim-7.1.042.ebuild,v 1.8 2007/10/10 06:44:32 opfer Exp $

EAPI="prefix"

inherit vim

VIM_VERSION="7.1"
VIM_GENTOO_PATCHES="vim-${VIM_VERSION}-gentoo-patches.tar.bz2"
VIM_ORG_PATCHES="vim-patches-${PV}.tar.gz"
GVIMRC_FILE_SUFFIX="-r1"
PREFIX_VER="1"

SRC_URI="ftp://ftp.vim.org/pub/vim/unstable/unix/vim-${VIM_VERSION}.tar.bz2
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-lang.tar.gz
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-extra.tar.gz
	mirror://gentoo/${VIM_GENTOO_PATCHES}
	mirror://gentoo/${VIM_ORG_PATCHES}
	http://dev.gentoo.org/~grobian/distfiles/vim-misc-prefix-${PREFIX_VER}.tar.bz2"

S="${WORKDIR}/vim${VIM_VERSION/.}"
DESCRIPTION="GUI version of the Vim text editor"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="aqua gnome gtk motif nextaw"
DEPEND="${DEPEND}
	~app-editors/vim-core-${PV}
	x11-libs/libXext
	!aqua? (
		gtk? (
			>=x11-libs/gtk+-2.6
			virtual/xft
			gnome? ( >=gnome-base/libgnomeui-2.6 )
		)
		!gtk? (
			motif? (
				x11-libs/openmotif
			)
			!motif? (
				nextaw? (
					x11-libs/neXtaw
				)
				!nextaw? ( x11-libs/libXaw )
			)
		)
	)"
