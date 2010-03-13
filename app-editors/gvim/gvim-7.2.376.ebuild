# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/gvim/gvim-7.2.376.ebuild,v 1.1 2010/02/24 17:00:08 lack Exp $

EAPI=2
inherit vim

VIM_VERSION="7.2"
VIM_GENTOO_PATCHES="vim-${VIM_VERSION}-gentoo-patches-r2.tar.bz2"
VIM_ORG_PATCHES="vim-patches-${PV}.tar.gz"
GVIMRC_FILE_SUFFIX="-r1"
GVIM_DESKTOP_SUFFIX="-r2"
PREFIX_VER="5"

SRC_URI="ftp://ftp.vim.org/pub/vim/unstable/unix/vim-${VIM_VERSION}.tar.bz2
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-lang.tar.gz
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-extra.tar.gz
	mirror://gentoo/${VIM_ORG_PATCHES}
	http://dev.gentoo.org/~grobian/distfiles/vim-misc-prefix-${PREFIX_VER}.tar.bz2"

S="${WORKDIR}/vim${VIM_VERSION/.}"
DESCRIPTION="GUI version of the Vim text editor"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

src_unpack() {
	vim_src_unpack || die "vim_src_unpack failed"

	epatch "${FILESDIR}"/${PN}-7.1.285-darwin-x11link.patch
	if [[ ${CHOST} == *-interix* ]]; then
		epatch "${FILESDIR}"/${PN}-7.1-interix-link.patch
		epatch "${FILESDIR}"/${PN}-7.1.319-interix-cflags.patch
	fi
}

src_compile() {
	if [[ ${CHOST} == *-interix* ]]; then
		export ac_cv_func_sigaction=no
	fi
	vim_src_compile || die "vim_src_compile failed"
}
