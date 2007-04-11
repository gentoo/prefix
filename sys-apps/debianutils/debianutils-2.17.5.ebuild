# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/debianutils/debianutils-2.17.5.ebuild,v 1.1 2007/03/03 05:14:29 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic autotools

DESCRIPTION="A selection of tools from Debian"
HOMEPAGE="http://packages.debian.org/unstable/utils/debianutils"
SRC_URI="mirror://debian/pool/main/d/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="static"

PDEPEND="sys-apps/mktemp"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.14.1-no-bs-namespace.patch
	epatch "${FILESDIR}"/${PN}-2.16.2-palo.patch
	epatch "${FILESDIR}"/${PN}-2.17.5-nongnu.patch
}

src_compile() {
	use static && append-ldflags -static
	eautoreconf || die
	econf || die
	emake || die
}

src_install() {
	into /
	dobin tempfile run-parts || die
	dosbin installkernel || die "installkernel failed"

	into /usr
	dosbin savelog mkboot || die "savelog/mkboot failed"

	doman tempfile.1 run-parts.8 savelog.8 installkernel.8 mkboot.8
	cd debian
	dodoc changelog control
}
