# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/tmux/tmux-0.8.ebuild,v 1.4 2009/05/27 10:25:11 fauli Exp $

inherit toolchain-funcs

DESCRIPTION="Terminal multiplexer"
HOMEPAGE="http://tmux.sourceforge.net"
SRC_URI="mirror://sourceforge/tmux/${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="vim-syntax"

DEPEND=""
RDEPEND="vim-syntax? ( || (
			app-editors/gvim
			app-editors/vim ) )"

src_compile() {
	emake CC="$(tc-getCC)" DEBUG="" FDEBUG="" || die "emake failed"
}

src_install() {
	dobin tmux || die "dobin failed"

	dodoc CHANGES FAQ NOTES TODO || die "dodoc failed"
	docinto examples
	dodoc examples/*.conf || die "dodoc examples failed"

	doman tmux.1 || die "doman failed"

	if use vim-syntax; then
		insinto /usr/share/vim/vimfiles/syntax
		doins examples/tmux.vim || die "doins syntax failed"

		insinto /usr/share/vim/vimfiles/ftdetect
		doins "${FILESDIR}"/tmux.vim || die "doins ftdetect failed"
	fi
}

pkg_preinst() {
	has_version "<${CATEGORY}/${PN}-0.6"
	PREVIOUS_LESS_THAN_0_6=$?
}

pkg_postinst() {
	if [[ ${PREVIOUS_LESS_THAN_0_6} -eq 0 ]]; then
		ewarn "The 0.6 release changed some commands and options"
		ewarn "(such as: mode-keys, remain-by-default, set, setw, and"
		ewarn "utf8-default), thus it will break current configurations. For"
		ewarn "more information, please refer to the files located in"
		ewarn "/usr/share/doc/${PF}."
	fi
}
