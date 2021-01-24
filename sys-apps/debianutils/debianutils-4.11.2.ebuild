# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic autotools

DESCRIPTION="A selection of tools from Debian"
HOMEPAGE="https://packages.qa.debian.org/d/debianutils.html"
SRC_URI="mirror://debian/pool/main/d/${PN}/${PN}_${PV}.tar.xz
	https://dev.gentoo.org/~grobian/distfiles/${PN}-4-nongnu.patch"

LICENSE="BSD GPL-2 SMAIL"
SLOT="0"
KEYWORDS="~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="+installkernel static"

PDEPEND="
	installkernel? (
		|| (
			sys-kernel/installkernel-gentoo
			sys-kernel/installkernel-systemd-boot
		)
	)"

S="${WORKDIR}/${PN}"

PATCHES=(
	"${FILESDIR}"/${PN}-3.4.2-no-bs-namespace.patch
	"${DISTDIR}"/${PN}-4-nongnu.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	use static && append-ldflags -static
	default
}

src_install() {
	into /
	dobin tempfile run-parts

	into /usr
	dobin ischroot
	dosbin savelog

	doman ischroot.1 tempfile.1 run-parts.8 savelog.8
	cd debian || die
	dodoc changelog control
}
