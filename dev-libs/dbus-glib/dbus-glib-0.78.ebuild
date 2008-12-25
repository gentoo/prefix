# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/dbus-glib/dbus-glib-0.78.ebuild,v 1.1 2008/12/23 22:27:08 cardoe Exp $

EAPI="prefix"

inherit eutils multilib autotools bash-completion

DESCRIPTION="D-Bus bindings for glib"
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/${PN}/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="bash-completion debug doc selinux test"

RDEPEND=">=sys-apps/dbus-1.1.0
	>=dev-libs/glib-2.10
	selinux? ( sys-libs/libselinux )
	>=dev-libs/expat-1.95.8"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( app-doc/doxygen app-text/xmlto )"

BASH_COMPLETION_NAME="dbus"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-introspection.patch

	epatch "${FILESDIR}"/${P}-as-needed.patch
	eautoreconf
}

src_compile() {
	econf \
		$(use_enable bash-completion) \
		$(use_enable selinux) \
		$(use_enable debug verbose-mode) \
		$(use_enable debug checks) \
		$(use_enable debug asserts) \
		$(use_enable test tests) \
		$(use_with test test-socket-dir ${T}/dbus-test-socket) \
		--with-system-pid-file="${EPREFIX}"/var/run/dbus.pid \
		--with-system-socket="${EPREFIX}"/var/run/dbus/system_bus_socket \
		--with-session-socket-dir="${EPREFIX}"/tmp \
		--with-dbus-user=messagebus \
		--localstatedir="${EPREFIX}"/var \
		$(use_enable doc doxygen-docs) \
		--disable-xml-docs \
		|| die "econf failed"

	# after the compile, it uses a selinuxfs interface to
	# check if the SELinux policy has the right support
	use selinux && addwrite /selinux/access

	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc AUTHORS ChangeLog HACKING NEWS README

	#FIXME: We need --with-bash-completion-dir
	if use bash-completion ; then
		dobashcompletion "${ED}"/etc/profile.d/dbus-bash-completion.sh
		rm -rf "${ED}"/etc/profile.d
	fi
}
