# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/bubblemon/bubblemon-1.46-r1.ebuild,v 1.1 2007/05/28 14:56:32 drac Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="A fun monitoring applet for your desktop, complete with swimming duck"
HOMEPAGE="http://www.ne.jp/asahi/linux/timecop"
SRC_URI="http://www.ne.jp/asahi/linux/timecop/software/${PN}-dockapp-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=x11-libs/gtk+-2"
RDEPEND="${DEPEND}"

S="${WORKDIR}"/${PN}-dockapp-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-gtk.patch
}

src_compile() {
	emake GENTOO_CFLAGS="${CFLAGS}" || die "emake failed."
}

src_install () {
	dobin bubblemon

	dodoc ChangeLog README doc/Xdefaults.sample

	insinto /usr/share/${PN}
	doins misc/{*.xcf,*.wav}

	exeinto /usr/share/${PN}
	doexe misc/wakwak.sh
}
