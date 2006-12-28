# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/zsh-completion/zsh-completion-20050503.ebuild,v 1.2 2006/09/03 06:04:37 vapier Exp $

EAPI="prefix"

DESCRIPTION="Programmable Completion for zsh (includes emerge and ebuild commands)"
HOMEPAGE="http://www.zsh.org/"
SRC_URI="http://dev.gentoo.org/~usata/distfiles/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ia64 ~ppc-macos"
IUSE=""

DEPEND="app-shells/zsh"

#S="${WORKDIR}/${PN}"

src_install() {

	insinto /usr/share/zsh/site-functions
	doins _*

	dodoc README
}

pkg_postinst() {
	einfo
	einfo "If you happen to compile your functions, you may need to delete"
	einfo "~/.zcompdump{,.zwc} and recompile to make zsh-completion available"
	einfo "to your shell."
	einfo
}
