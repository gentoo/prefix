# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit git vim autotools

EGIT_REPO_URI="git://repo.or.cz/MacVim.git"

DESCRIPTION="Cocoa GUI for the famous editor"
HOMEPAGE="http://code.google.com/p/macvim"
SRC_URI=""

LICENSE="vim"
SLOT="0"
KEYWORDS="~x86-macos"
IUSE=""

#RDEPEND="~app-editors/vim-core-${PV}"
RDEPEND=""
DEPEND="${RDEPEND}"


src_unpack() {
	git_src_unpack
	cd "${S}"
	cp "${FILESDIR}"/Makefile "${S}"/src/MacVim
	eprefixify "${S}"/src/MacVim/Makefile
	epatch "${FILESDIR}"/${PN}-info-plist.patch
	epatch "${FILESDIR}"/${PN}-prefix.patch
	eprefixify "${S}"/src/MacVim/mvim

	# two patches that were copied from vim
	epatch "${FILESDIR}"/with-local-dir.patch
	epatch "${FILESDIR}"/${PN}-optimize.patch
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
	cd "${S}"/src/MacVim
	emake install DESTDIR="${D}"
	dobin "${S}"/src/MacVim/mvim
}
