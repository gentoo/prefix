# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/nmap/nmap-4.20.ebuild,v 1.9 2007/05/06 15:17:36 spock Exp $

EAPI="prefix"

inherit eutils flag-o-matic
DESCRIPTION="A utility for network exploration or security auditing"
HOMEPAGE="http://www.insecure.org/nmap/"
SRC_URI="http://download.insecure.org/nmap/dist/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="gtk ssl"

DEPEND="virtual/libc
	dev-libs/libpcre
	gtk? ( =x11-libs/gtk+-2* )
	ssl? ( dev-libs/openssl )"

src_unpack() {
	unpack ${A}
	cd ${S}
	sed 's:Icon=icon-network:Icon=nmap-logo-64.png:' -i nmapfe.desktop
	echo ";" >> nmapfe.desktop
	epatch ${FILESDIR}/nmap-shtool-nls.patch
	epatch ${FILESDIR}/nmap-4.01-nostrip.patch
	epatch ${FILESDIR}/${P}-osscan.patch
}

src_compile() {
	use ppc-macos && filter-flags -fstrict-aliasing -O2
	econf \
		$(use_with gtk nmapfe) \
		$(use_with ssl openssl) || die
	emake -j1 || die
}

src_install() {
	einstall -j1 nmapdatadir=${ED}/usr/share/nmap install || die
	dodoc CHANGELOG HACKING docs/README docs/*.txt
	dohtml docs/*.html

	if use gtk; then
		dodir /usr/share/pixmaps
		insinto /usr/share/pixmaps
		doins ${FILESDIR}/nmap-logo-64.png
	fi
}
