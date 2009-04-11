# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/wgetpaste/wgetpaste-2.12.ebuild,v 1.8 2009/03/17 13:57:06 armin76 Exp $

DESCRIPTION="Command-line interface to various pastebins"
HOMEPAGE="http://wgetpaste.zlin.dk/"
SRC_URI="http://wgetpaste.zlin.dk/${P}.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}

src_install() {
	newbin ${P} ${PN}
}

pkg_postinst() {
	local f oldfiles=()
	for f in "${EROOT}"etc/wgetpaste{,.d/*.bash}; do
		oldfiles+=("${f}")
	done

	if [[ -n ${oldfiles[@]} ]]; then
		ewarn "The config files for wgetpaste have changed to *.conf."
		ewarn
		for f in "${oldfiles[@]}"; do
			ewarn "Please move ${f} to ${f%.bash}.conf"
		done
		ewarn
		ewarn "Users with personal config files will need to do the same for"
		ewarn "~/.wgetpaste and ~/.wgetpaste.d/*.bash."
	fi
}
