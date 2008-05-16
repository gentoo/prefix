# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-ubuntulooks/gtk-engines-ubuntulooks-0.9.12-r2.ebuild,v 1.1 2008/05/14 08:41:38 drac Exp $

EAPI="prefix"

inherit eutils autotools

PATCH_LEVEL=11

MY_PN=${PN/gtk-engines-/}

DESCRIPTION="a derivative of the standard Clearlooks engine, using a more orange approach"
HOMEPAGE="http://packages.ubuntu.com/intrepid/gtk2-engines-ubuntulooks"
SRC_URI="http://archive.ubuntu.com/ubuntu/pool/main/u/${MY_PN}/${MY_PN}_${PV}.orig.tar.gz
	http://archive.ubuntu.com/ubuntu/pool/main/u/${MY_PN}/${MY_PN}_${PV}-${PATCH_LEVEL}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.8"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/${MY_PN}-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${MY_PN}_${PV}-${PATCH_LEVEL}.diff
	EPATCH_FORCE="yes" EPATCH_SUFFIX="patch" epatch debian/patches

	eautoreconf # need new libtool for interix
}

src_compile() {
	econf --disable-dependency-tracking --enable-animation
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog README
	newdoc debian/changelog ChangeLog.debian
}
