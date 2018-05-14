# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/debianutils/debianutils-4.4.ebuild,v 1.12 2014/01/26 12:18:12 ago Exp $

EAPI=4

inherit eutils flag-o-matic autotools

DESCRIPTION="A selection of tools from Debian"
HOMEPAGE="http://packages.qa.debian.org/d/debianutils.html"
SRC_URI="mirror://debian/pool/main/d/${PN}/${PN}_${PV}.tar.gz"

LICENSE="BSD GPL-2 SMAIL"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="kernel_linux static"

PDEPEND="|| ( >=sys-apps/coreutils-6.10-r1 sys-freebsd/freebsd-ubin )"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-3.4.2-no-bs-namespace.patch
	epatch "${FILESDIR}"/${PN}-4-nongnu.patch
	eautoreconf || die
}

src_configure() {
	use static && append-ldflags -static
	default
}

src_install() {
	into /
	dobin tempfile run-parts
	if use kernel_linux ; then
		dosbin installkernel
	fi

	into /usr
	dosbin savelog

	doman tempfile.1 run-parts.8 savelog.8
	use kernel_linux && doman installkernel.8
	cd debian
	dodoc changelog control
	keepdir /etc/kernel/postinst.d
}