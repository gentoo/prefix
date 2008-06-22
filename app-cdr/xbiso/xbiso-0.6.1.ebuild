# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/xbiso/xbiso-0.6.1.ebuild,v 1.5 2008/06/21 08:18:17 opfer Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="Xbox xdvdfs ISO extraction utility"
HOMEPAGE="http://sourceforge.net/projects/xbiso/"
SRC_URI="mirror://sourceforge/xbiso/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

src_compile() {
	# for this package, interix behaves the same as BSD
	[[ ${CHOST} == *-interix* ]] && append-flags -D_BSD

	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	dobin xbiso || die "dobin failed."
	dodoc CHANGELOG README
}
