# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/gvim/gvim-7.1.266.ebuild,v 1.7 2008/04/07 22:43:36 armin76 Exp $

EAPI="prefix"

inherit vim autotools

VIM_VERSION="7.1"
VIM_GENTOO_PATCHES="vim-${VIM_VERSION}-gentoo-patches.tar.bz2"
VIM_ORG_PATCHES="vim-patches-${PV}.tar.gz"
GVIMRC_FILE_SUFFIX="-r1"
GVIM_DESKTOP_SUFFIX="-r1"
PREFIX_VER="4"

SRC_URI="ftp://ftp.vim.org/pub/vim/unstable/unix/vim-${VIM_VERSION}.tar.bz2
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-lang.tar.gz
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-extra.tar.gz
	mirror://gentoo/${VIM_GENTOO_PATCHES}
	mirror://gentoo/${VIM_ORG_PATCHES}
	http://dev.gentoo.org/~grobian/distfiles/vim-misc-prefix-${PREFIX_VER}.tar.bz2"

S="${WORKDIR}/vim${VIM_VERSION/.}"
DESCRIPTION="GUI version of the Vim text editor"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="gnome gtk motif nextaw aqua carbon"
DEPEND="${DEPEND}
	~app-editors/vim-core-${PV}
	!aqua? (
		x11-libs/libXext
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
	)
	aqua? ( >=sys-apps/portage-2.2.00.9133 )"

pkg_setup() {
	vim_pkg_setup
	if use aqua && ! ( built_with_use app-editors/vim-core aqua ); then
		die "vim-core was not built with USE aqua"
	fi
	if use aqua && use carbon ; then
		die "you cannot build both the Cocoa and Carbon applications"
	fi
}

src_unpack() {
	vim_src_unpack || die
	if use aqua; then
		for aqua_file in MacVim proto/gui_macvim.pro; do
			mv "${WORKDIR}"/vim-misc-prefix/src/${aqua_file} "${S}"/src
		done
		#rm -f "${S}"/src/auto/config.{h,mk}
		eprefixify "${S}"/src/MacVim/Makefile
		epatch "${FILESDIR}"/macvim-info-plist.patch
		epatch "${FILESDIR}"/macvim-prefix.patch
		eprefixify "${S}"/src/MacVim/mvim
		epatch "${FILESDIR}"/macvim-runtime.patch
		eprefixify src/MacVim/gui_macvim.m
	fi
}

src_compile() {
	vim_src_compile
	if use aqua; then
		cd "${S}"/src/MacVim
		emake CFLAGS="${CFLAGS}" CC="$(tc-getCC)" || die "making MacVim failed"
	fi
}

src_install() {
	if ! use aqua; then
		vim_src_install
	else
		cd "${S}"/src/MacVim
		emake install DESTDIR="${D}"
		dobin "${S}"/src/MacVim/mvim
		dodir /etc/vim
		cp "${S}"/src/MacVim/gvimrc "${ED}"/etc/vim/
	fi
}
