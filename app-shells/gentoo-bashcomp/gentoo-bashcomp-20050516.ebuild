# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-shells/gentoo-bashcomp/gentoo-bashcomp-20050516.ebuild,v 1.10 2005/11/25 21:01:50 tgall Exp $

EAPI="prefix"

DESCRIPTION="Gentoo-specific bash command-line completions (emerge, ebuild, equery, etc)"
HOMEPAGE="http://developer.berlios.de/projects/gentoo-bashcomp/"
SRC_URI="http://download.berlios.de/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

RDEPEND=">=app-shells/bash-completion-20050121-r3"

src_install() {
	emake DESTDIR="${ED}" install || die "make install failed"
	dodoc AUTHORS ChangeLog TODO NEWS
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
