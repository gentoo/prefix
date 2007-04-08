# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/ccache/ccache-2.4-r6.ebuild,v 1.14 2007/03/05 03:26:45 genone Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
inherit eutils autotools

DESCRIPTION="fast compiler cache"
HOMEPAGE="http://ccache.samba.org/"
SRC_URI="http://samba.org/ftp/ccache/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

# Note: this version is designed to be auto-detected and used if
# you happen to have Portage 2.0.X+ installed.

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/ccache-2.4-respectflags.patch
	epatch "${FILESDIR}"/ccache-2.4-utimes.patch
	eautoconf
}

do_links() {
	insinto /usr/lib/ccache/bin
	for a in ${CHOST}-{gcc,g++,c++} gcc c++ g++; do
	    dosym /usr/bin/ccache /usr/lib/ccache/bin/${a}
	done
}


src_install() {
	dobin ccache || die
	doman ccache.1
	dodoc README
	dohtml web/*.html

	diropts -m0755
	dodir /usr/lib/ccache/bin
	keepdir /usr/lib/ccache/bin

	dobin "${FILESDIR}"/ccache-config || die
}

pkg_preinst() {
	einfo "Scanning for compiler front-ends..."
	do_links
}

pkg_postinst() {
	# nuke broken symlinks from previous versions that shouldn't exist
	for i in cc ${CHOST}-cc ; do
	    [[ -L "${EROOT}/usr/lib/ccache/bin/${i}" ]] && rm -rf "${EROOT}/usr/lib/ccache/bin/${i}"
	done
	[[ -d "${EROOT}/usr/lib/ccache.backup" ]] && rm -fr "${EROOT}/usr/lib/ccache.backup"

	elog "To use ccache with **non-Portage** C compiling, add"
	elog "/usr/lib/ccache/bin to the beginning of your path, before /usr/bin."
	elog "Portage 2.0.46-r11+ will automatically take advantage of ccache with"
	elog "no additional steps.  If this is your first install of ccache, type"
	elog "something like this to set a maximum cache size of 2GB:"
	elog "# ccache -M 2G"
}
