# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/gvim/gvim-7.1.164.ebuild,v 1.1 2007/11/30 06:16:47 hawking Exp $

EAPI="prefix"

inherit vim autotools

VIM_VERSION="7.1"
VIM_GENTOO_PATCHES="vim-${VIM_VERSION}-gentoo-patches.tar.bz2"
VIM_ORG_PATCHES="vim-patches-${PV}.tar.gz"
GVIMRC_FILE_SUFFIX="-r1"
GVIM_DESKTOP_SUFFIX="-r1"

SRC_URI="ftp://ftp.vim.org/pub/vim/unstable/unix/vim-${VIM_VERSION}.tar.bz2
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-lang.tar.gz
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-extra.tar.gz
	mirror://gentoo/${VIM_GENTOO_PATCHES}
	mirror://gentoo/${VIM_ORG_PATCHES}
	aqua? ( http://dev.gentooexperimental.org/~pipping/distfiles/macvim-${PV}.tbz2 )"

S="${WORKDIR}/vim${VIM_VERSION/.}"
DESCRIPTION="GUI version of the Vim text editor"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE="aqua gnome gtk motif nextaw"
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
	)"

pkg_setup() {
	vim_pkg_setup
	if use aqua && ! ( built_with_use app-editors/vim-core aqua ); then
		die "vim-core was not built with USE aqua"
	fi
}

src_unpack() {
	vim_src_unpack || die
	if use aqua; then
		for aqua_file in MacVim proto/gui_macvim.pro; do
			mv "${WORKDIR}"/macvim-${PV}/src/${aqua_file} "${S}"/src
		done
		#rm -f "${S}"/src/auto/config.{h,mk}
		eprefixify "${S}"/src/MacVim/Makefile
		epatch "${FILESDIR}"/macvim-info-plist.patch
		epatch "${FILESDIR}"/macvim-prefix.patch
		eprefixify "${S}"/src/MacVim/mvim
	fi

	# two patches that were copied from vim
	epatch "${FILESDIR}"/with-local-dir.patch
	epatch "${FILESDIR}"/vim-optimize.patch
	(
		cd "${S}"/src
		eautoreconf
	)
}

src_compile() {
	EXTRA_ECONF="--without-local-dir"
	vim_src_compile
	cd "${S}"/src/MacVim
	emake CFLAGS="${CFLAGS}" CC="$(tc-getCC)" || die "making MacVim failed"
}

src_install() {
	if ! use aqua; then
		vim_src_install
	else
		cd "${S}"/src/MacVim
		emake install DESTDIR="${D}"
		dobin "${S}"/src/MacVim/mvim
	fi
}
