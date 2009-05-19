# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-auth/consolekit/consolekit-0.2.10.ebuild,v 1.11 2009/05/17 01:02:38 vapier Exp $

inherit eutils autotools multilib pam

MY_PN="ConsoleKit"
MY_PV="${PV//_pre*/}"

DESCRIPTION="Framework for defining and tracking users, login sessions and seats."
HOMEPAGE="http://www.freedesktop.org/wiki/Software/ConsoleKit"
SRC_URI="http://people.freedesktop.org/~mccann/dist/${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug pam"

# Not parallel make safe
MAKEOPTS="$MAKEOPTS -j1"

RDEPEND=">=dev-libs/glib-2.16
	>=dev-libs/dbus-glib-0.61
	>=x11-libs/libX11-1.0.0
	pam? ( virtual/pam )
	elibc_glibc? ( !=sys-libs/glibc-2.4* )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_PN}-${MY_PV}"

src_compile() {
	econf $(use_enable debug) \
	$(use_enable pam pam-module) \
	--with-pam-module-dir=/$(getpam_mod_dir) \
	--with-pid-file=/var/run/consolekit.pid \
	--with-dbus-services=/usr/share/dbus-1/services/ \
	|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	#crappy Redhat init script
	rm -f "${ED}/etc/rc.d/init.d/ConsoleKit"
	rm -r "${ED}/etc/rc.d/"

	#Portage barfs on .la files
	rm -f "${ED}/$(get_libdir)/security/pam_ck_connector.la"

	# Gentoo style init script
	newinitd "${FILESDIR}"/${PN}-0.1.rc consolekit
}

pkg_postinst() {
	ewarn
	ewarn "You need to restart ConsoleKit to get the new features."
	ewarn "This can be done with /etc/init.d/consolekit restart"
	ewarn "but make sure you do this and then restart your session"
	ewarn "otherwise you will get access denied for certain actions"
	ewarn
}
