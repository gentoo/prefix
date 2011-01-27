# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/pcsc-lite/pcsc-lite-1.6.6.ebuild,v 1.8 2011/01/10 11:09:39 xarthisius Exp $

EAPI="3"

inherit multilib eutils

DESCRIPTION="PC/SC Architecture smartcard middleware library"
HOMEPAGE="http://pcsclite.alioth.debian.org/"

STUPID_NUM="3479"
MY_P="${PN}-${PV/_/-}"
SRC_URI="http://alioth.debian.org/download.php/${STUPID_NUM}/${MY_P}.tar.bz2"
S="${WORKDIR}/${MY_P}"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE="usb kernel_linux"

RDEPEND="usb? ( virtual/libusb:1 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
RDEPEND="${RDEPEND}
	!<app-crypt/ccid-1.4.1-r1
	kernel_linux? ( sys-fs/udev )"

pkg_setup() {
	enewgroup pcscd
}

src_configure() {
	econf \
		--disable-maintainer-mode \
		--disable-dependency-tracking \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		--enable-usbdropdir="${EPREFIX}/usr/$(get_libdir)/readers/usb" \
		--enable-confdir="${EPREFIX}"/etc \
		$(use_enable usb libusb) \
		--disable-libhal
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS DRIVERS HELP README SECURITY ChangeLog || die

	newinitd "${FILESDIR}/pcscd-init.3" pcscd || die

	if use kernel_linux; then
		insinto /lib/udev/rules.d
		doins "${FILESDIR}"/99-pcscd-hotplug.rules || die
	fi
}

pkg_postinst() {
	elog "Starting from version 1.6.5, pcsc-lite will start as user nobody in"
	elog "the pcscd group, to avoid running as root."
	elog ""
	elog "This also means you need the newest drivers available so that the"
	elog "devices get the proper owner."
	elog ""
	elog "Furthermore, a conf.d file is no longer installed by default, as"
	elog "the default configuration does not require one. If you need to"
	elog "pass further options to pcscd, create a file and set the"
	elog "EXTRA_OPTS variable."
	elog ""
	if use kernel_linux; then
		elog "HAL support has been dropped by the ebuild; if you want hotplug"
		elog "support, that's provided already by UDEV rules; you only need to"
		elog "tell the init system to hotplug it, by setting this variable in"
		elog "/etc/rc.conf:"
		elog ""
		elog "    rc_hotplug=\"pcscd\""
	fi
}
