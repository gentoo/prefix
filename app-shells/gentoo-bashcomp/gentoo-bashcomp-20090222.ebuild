# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/gentoo-bashcomp/gentoo-bashcomp-20090222.ebuild,v 1.6 2009/04/12 18:18:48 ranger Exp $

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
	doins gentoo || die "failed to install gentoo module"
	doins repoman || die "failed to install repoman module"
	dodoc AUTHORS ChangeLog TODO
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
	elog "to install system-wide. (and/or repoman instead of gentoo if you use"
	elog "repoman frequently)"
}
