# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/dbus-glib/dbus-glib-0.82-r1.ebuild,v 1.7 2010/05/15 16:47:41 armin76 Exp $

EAPI="2"

inherit bash-completion

DESCRIPTION="D-Bus bindings for glib"
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/${PN}/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="bash-completion debug doc test"

RDEPEND=">=sys-apps/dbus-1.1
	>=dev-libs/glib-2.10
	>=dev-libs/expat-1.95.8"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext
	doc? (
		app-doc/doxygen
		app-text/xmlto
		>=dev-util/gtk-doc-1.4 )"

BASHCOMPLETION_NAME="dbus"

src_configure() {
	econf \
		--enable-checks \
		--localstatedir="${EPREFIX}"/var \
		$(use_enable bash-completion) \
		$(use_enable debug verbose-mode) \
		$(use_enable debug asserts) \
		$(use_enable doc doxygen-docs) \
		$(use_enable doc gtk-doc) \
		$(use_enable test tests) \
		$(use_with test test-socket-dir "${T}"/dbus-test-socket)
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog HACKING NEWS README || die "dodoc failed."

	# FIXME: We need --with-bash-completion-dir
	if use bash-completion ; then
		dobashcompletion "${ED}"/etc/bash_completion.d/dbus-bash-completion.sh
		rm -rf "${ED}"/etc/bash_completion.d || die "rm failed"
	fi
}
