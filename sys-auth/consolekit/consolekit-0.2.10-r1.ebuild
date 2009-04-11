# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-auth/consolekit/consolekit-0.2.10-r1.ebuild,v 1.2 2009/03/17 22:48:43 loki_val Exp $

EAPI=2

inherit autotools eutils multilib pam

MY_PN="ConsoleKit"
MY_PV="${PV//_pre*/}"

DESCRIPTION="Framework for defining and tracking users, login sessions and seats."
HOMEPAGE="http://www.freedesktop.org/wiki/Software/ConsoleKit"
SRC_URI="http://people.freedesktop.org/~mccann/dist/${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug pam"

RDEPEND=">=dev-libs/glib-2.16
	>=dev-libs/dbus-glib-0.61
	>=x11-libs/libX11-1.0.0
	pam? ( virtual/pam )
	elibc_glibc? ( !=sys-libs/glibc-2.4* )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_PN}-${MY_PV}"

src_prepare() {
	# Fix directory leaks, bug #258685
	epatch "${FILESDIR}/${P}-directory-leak.patch"

	# Clean up at_console compat files, bug #257761
	epatch "${FILESDIR}/${P}-cleanup_console_tags.patch"

	# Add nox11 option to no interfere with Xsession script, bug #257763
	epatch "${FILESDIR}/${P}-pam-add-nox11.patch"

	# Fix automagic dependency on policykit
	epatch "${FILESDIR}/${P}-polkit-automagic.patch"

	eautoreconf
}

src_configure() {
	econf \
		$(use_enable debug) \
		$(use_enable pam pam-module) \
		--disable-polkit \
		--with-pam-module-dir=/$(getpam_mod_dir) \
		--with-pid-file=/var/run/consolekit.pid \
		--with-dbus-services=/usr/share/dbus-1/services/ \
		--localstatedir=/var
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# crappy Redhat init script
	rm -f "${ED}/etc/rc.d/init.d/ConsoleKit"

	# Portage barfs on .la files
	rm -f "${ED}/$(get_libdir)/security/pam_ck_connector.la"

	# Gentoo style init script
	newinitd "${FILESDIR}"/${PN}-0.1.rc consolekit

	# Some PM drop empty dirs, bug #257164
	keepdir /usr/$(get_libdir)/ConsoleKit/run-session.d
	keepdir /etc/ConsoleKit/run-session.d
	keepdir /var/run/ConsoleKit
	keepdir /var/log/ConsoleKit

	insinto /etc/X11/xinit/xinitrc.d/
	doins "${FILESDIR}/90-consolekit" || die "doins failed"

	exeinto /usr/$(get_libdir)/ConsoleKit/run-session.d/
	doexe "${FILESDIR}/pam-foreground-compat.ck" || die "doexe failed"
}

pkg_postinst() {
	ewarn
	ewarn "You need to restart ConsoleKit to get the new features."
	ewarn "This can be done with /etc/init.d/consolekit restart"
	ewarn "but make sure you do this and then restart your session"
	ewarn "otherwise you will get access denied for certain actions"

	ewarn
	ewarn "You need to chmod +x /etc/X11/xinit/xinitrc.d/90-consolekit"
	ewarn "to benefit of consolekit if you are not using gdm or pam integration."
}
