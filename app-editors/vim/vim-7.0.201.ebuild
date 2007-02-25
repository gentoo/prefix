# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/vim/vim-7.0.201.ebuild,v 1.1 2007/02/24 07:01:27 pioto Exp $

EAPI="prefix"

inherit vim

VIM_VERSION="7.0"
VIM_SNAPSHOT="vim-7.0-r1.tar.bz2"
VIM_GENTOO_PATCHES="vim-7.0-gentoo-patches-r1.tar.bz2"
VIM_ORG_PATCHES="vim-patches-${PV}.tar.gz"

SRC_URI="${SRC_URI}
	mirror://gentoo/${VIM_SNAPSHOT}
	mirror://gentoo/${VIM_GENTOO_PATCHES}
	mirror://gentoo/${VIM_ORG_PATCHES}"

S=${WORKDIR}/vim${VIM_VERSION/.*}
DESCRIPTION="Vim, an improved vi-style text editor"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""
PROVIDE="virtual/editor"
DEPEND="${DEPEND}
	!minimal? ( ~app-editors/vim-core-${PV} )"
RDEPEND="${RDEPEND}
	!<app-editors/nvi-1.81.5-r4
	!minimal? ( ~app-editors/vim-core-${PV} )"

src_unpack() {
	vim_src_unpack || die
	epatch ${FILESDIR}/with-local-dir.patch || die
}

src_compile() {
	[[ ${EPREFIX%/} != "" ]] && EXTRA_ECONF="--without-local-dir"
	vim_src_compile || die
}
