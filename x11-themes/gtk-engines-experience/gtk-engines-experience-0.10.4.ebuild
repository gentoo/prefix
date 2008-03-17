# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-experience/gtk-engines-experience-0.10.4.ebuild,v 1.4 2007/07/25 21:06:09 angelos Exp $

EAPI="prefix"

inherit autotools

MY_PN="experience"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="GTK+2 Experience Theme Engine"
HOMEPAGE="http://benjamin.sipsolutions.net/Projects/eXperience"
SRC_URI="http://benjamin.sipsolutions.net/${MY_PN}/${MY_P}.tar.bz2"

KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""
LICENSE="LGPL-2"
SLOT="2"

RDEPEND=">=x11-libs/gtk+-2.6"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9"

S="${WORKDIR}/${P/engines/engine}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	eautoreconf # need new libtool for interix
}

src_compile() {
	econf || die "Configuration failed"
	emake || die "Compilation failed"
}

src_install() {
	make DESTDIR="${D}" install || die "Installation failed"

	dodoc AUTHORS ChangeLog NEWS README TODO
}
