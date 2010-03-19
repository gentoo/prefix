# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/vim/vim-7.2.376.ebuild,v 1.1 2010/02/24 16:56:14 lack Exp $

EAPI=2
inherit vim

VIM_VERSION="7.2"
VIM_ORG_PATCHES="vim-patches-${PV}.tar.gz"

SRC_URI="ftp://ftp.vim.org/pub/vim/unix/vim-${VIM_VERSION}.tar.bz2
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-lang.tar.gz
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-extra.tar.gz
	mirror://gentoo/${VIM_ORG_PATCHES}"

S="${WORKDIR}/vim${VIM_VERSION/.}"
DESCRIPTION="Vim, an improved vi-style text editor"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

src_prepare() {
	vim_src_prepare

	if [[ ${CHOST} == *-interix* ]]; then
		epatch "${FILESDIR}"/${PN}-7.1-interix-link.patch
		epatch "${FILESDIR}"/${PN}-7.1.319-interix-cflags.patch
	fi
	epatch "${FILESDIR}"/${PN}-7.1.285-darwin-x11link.patch
}

src_compile() {
	if [[ ${CHOST} == *-interix* ]]; then
		# avoid finding of this function, to avoid having to patch either
		# configure or the source, which would be much more hackish.  after all
		# vim does it right, only interix is badly broken (again).
		export ac_cv_func_sigaction=no
	fi
	vim_src_compile || die "vim_src_compile failed"
}
