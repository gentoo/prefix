# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-ubuntulooks/gtk-engines-ubuntulooks-0.9.12-r1.ebuild,v 1.3 2007/12/22 18:16:47 nixnut Exp $

EAPI="prefix"

inherit eutils autotools

PATCH_LEVEL=8

MY_PN=${PN/gtk-engines-/}

DESCRIPTION="a derivative of the standard Clearlooks engine, using a more orange approach"
HOMEPAGE="http://packages.ubuntu.com/gutsy/gnome/gtk2-engines-ubuntulooks"
SRC_URI="http://archive.ubuntu.com/ubuntu/pool/main/u/${MY_PN}/${MY_PN}_${PV}.orig.tar.gz
	http://archive.ubuntu.com/ubuntu/pool/main/u/${MY_PN}/${MY_PN}_${PV}-${PATCH_LEVEL}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.8"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}"/${MY_PN}-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${MY_PN}_${PV}-${PATCH_LEVEL}.diff
	epatch debian/patches/*.patch

	eautoreconf # need new libtool for interix
}

src_compile() {
	econf --enable-animation
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog README
}
