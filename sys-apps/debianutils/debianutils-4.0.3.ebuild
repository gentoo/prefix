# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/debianutils/debianutils-4.0.3.ebuild,v 1.1 2011/10/10 08:46:14 radhermit Exp $

inherit eutils flag-o-matic autotools

DESCRIPTION="A selection of tools from Debian"
HOMEPAGE="http://packages.qa.debian.org/d/debianutils.html"
SRC_URI="mirror://debian/pool/main/d/${PN}/${PN}_${PV}.tar.gz"

LICENSE="BSD GPL-2 SMAIL"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="kernel_linux static"

PDEPEND="|| ( >=sys-apps/coreutils-6.10-r1 sys-freebsd/freebsd-ubin )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-3.4.2-no-bs-namespace.patch
	epatch "${FILESDIR}"/${PN}-4-nongnu.patch
	eautoreconf || die
}

src_compile() {
	use static && append-ldflags -static

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

	doman tempfile.1 run-parts.8 savelog.8
	use kernel_linux && doman installkernel.8
	cd debian
	dodoc changelog control
	keepdir /etc/kernel/postinst.d
}
