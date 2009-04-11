# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/debianutils/debianutils-2.29.ebuild,v 1.2 2008/08/08 13:00:11 jer Exp $

inherit eutils flag-o-matic autotools

DESCRIPTION="A selection of tools from Debian"
HOMEPAGE="http://packages.debian.org/unstable/utils/debianutils"
SRC_URI="mirror://debian/pool/main/d/${PN}/${PN}_${PV}.tar.gz"

LICENSE="BSD GPL-2 SMAIL"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="kernel_linux static"

PDEPEND="|| ( >=sys-apps/coreutils-6.10-r1 sys-apps/mktemp sys-freebsd/freebsd-ubin )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.28.2-no-bs-namespace.patch
	epatch "${FILESDIR}"/${PN}-2.28.2-mkboot-quiet.patch
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
	if use kernel_linux ; then
		dosbin installkernel || die "installkernel failed"
	fi

	into /usr
	dosbin savelog || die "savelog failed"
	if use kernel_linux ; then
		dosbin mkboot || die "mkboot failed"
	fi

	doman tempfile.1 run-parts.8 savelog.8
	use kernel_linux && doman installkernel.8 mkboot.8
	cd debian
	dodoc changelog control
}
