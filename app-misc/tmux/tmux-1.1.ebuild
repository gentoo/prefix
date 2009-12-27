# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/tmux/tmux-1.1.ebuild,v 1.3 2009/12/10 20:07:19 maekke Exp $

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
	# The configure script isn't created by GNU autotools.
	./configure || die "configure failed"
	emake CC="$(tc-getCC)" || die "emake failed"
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
	has_version "<${CATEGORY}/${PN}-1.1"
	PREVIOUS_LESS_THAN_1_1=$?
}

pkg_postinst() {
	if [[ ${PREVIOUS_LESS_THAN_1_1} -eq 0 ]]; then
		ewarn "The 1.1 release replaced the internal locking mechanism by"
		ewarn "executing an external command (you might want to install"
		ewarn "app-misc/vlock and set the lock-command session option"
		ewarn "accordingly), so the set-password command, and the -U command"
		ewarn "line flag were removed, as well as -d, since tmux will now"
		ewarn "automatically detect default colours."
	fi
}
