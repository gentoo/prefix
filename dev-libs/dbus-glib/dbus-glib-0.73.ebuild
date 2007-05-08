# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/dbus-glib/dbus-glib-0.73.ebuild,v 1.10 2007/04/22 18:15:51 dertobi123 Exp $

EAPI="prefix"

inherit eutils multilib autotools

DESCRIPTION="D-Bus bindings for glib"
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/${PN}/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE="doc selinux debug"

RDEPEND=">=sys-apps/dbus-0.94
	>=dev-libs/glib-2.6
	selinux? ( sys-libs/libselinux )
	>=dev-libs/libxml2-2.6.21"
	# expat code now sucks.. libxml2 is the default
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( app-doc/doxygen app-text/xmlto )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-introspection.patch
}

src_compile() {
	local myconf=""

	econf \
		$(use_enable selinux) \
		$(use_enable debug verbose-mode) \
		$(use_enable debug checks) \
		$(use_enable debug asserts) \
		--with-xml=libxml \
		--with-system-pid-file="${EPREFIX}"/var/run/dbus.pid \
		--with-system-socket="${EPREFIX}"/var/run/dbus/system_bus_socket \
		--with-session-socket-dir="${EPREFIX}"/tmp \
		--with-dbus-user=messagebus \
		--localstatedir="${EPREFIX}"/var \
		$(use_enable doc doxygen-docs) \
		--disable-xml-docs \
		${myconf} \
		|| die "econf failed"

	# after the compile, it uses a selinuxfs interface to
	# check if the SELinux policy has the right support
	use selinux && addwrite /selinux/access

	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc AUTHORS ChangeLog HACKING NEWS README
}
