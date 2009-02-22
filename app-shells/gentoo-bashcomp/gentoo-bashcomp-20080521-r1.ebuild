# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/gentoo-bashcomp/gentoo-bashcomp-20080521-r1.ebuild,v 1.1 2009/02/21 20:29:09 darkside Exp $

EAPI="prefix"

DESCRIPTION="Gentoo-specific bash command-line completions (emerge, ebuild, equery, etc)"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint"
IUSE=""

RDEPEND="app-shells/bash-completion"

src_install() {
	insinto /usr/share/bash-completion
	doins gentoo || die "doins failed"
	dodoc AUTHORS ChangeLog NEWS TODO
}

pkg_postinst() {
	# can't use bash-completion.eclass.
	elog "To enable command-line completion for ${PN}, run:"
	elog
	elog "  eselect bashcomp enable gentoo"
	elog
	elog "to install locally, or"
	elog
	elog "  eselect bashcomp enable --global gentoo"
	elog
	elog "to install system-wide."
}
