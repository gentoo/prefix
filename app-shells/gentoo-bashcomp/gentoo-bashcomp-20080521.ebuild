# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/gentoo-bashcomp/gentoo-bashcomp-20080521.ebuild,v 1.1 2008/05/21 19:00:17 nyhm Exp $

EAPI="prefix"

DESCRIPTION="Gentoo-specific bash command-line completions (emerge, ebuild, equery, etc)"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="app-shells/bash-completion"

src_install() {
	emake DESTDIR="${D}${EPREFIX}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS TODO
}

pkg_postinst() {
	local g="${EROOT}/etc/bash_completion.d/gentoo"
	if [[ -e "${g}" && ! -L "${g}" ]] ; then
		echo
		ewarn "The gentoo completion functions have moved to /usr/share/bash-completion."
		ewarn "Please run etc-update to replace /etc/bash_completion.d/gentoo with a symlink."
		echo
	fi
}
