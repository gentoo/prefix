# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-keyring/gnome-keyring-2.26.1-r1.ebuild,v 1.2 2009/06/30 07:50:28 aballier Exp $

EAPI="2"

inherit gnome2 pam virtualx eutils autotools

DESCRIPTION="Password and keyring managing daemon"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="debug doc hal pam test"
# USE=valgrind is probably not a good idea for the tree

RDEPEND=">=dev-libs/glib-2.16
	>=x11-libs/gtk+-2.6
	gnome-base/gconf
	>=sys-apps/dbus-1.0
	hal? ( >=sys-apps/hal-0.5.7 )
	pam? ( virtual/pam )
	>=dev-libs/libgcrypt-1.2.2
	>=dev-libs/libtasn1-1"
#	valgrind? ( dev-util/valgrind )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9
	doc? ( >=dev-util/gtk-doc-1.9 )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable debug)
		$(use_enable hal)
		$(use_enable test tests)
		$(use_enable pam)
		$(use_with pam pam-dir $(getpam_mod_dir))
		--with-root-certs=${EPREFIX}/usr/share/ca-certificates/
		--enable-acl-prompts
		--enable-ssh-agent"
}

src_prepare() {
	gnome2_src_prepare

	# Remove silly CFLAGS
	sed 's:CFLAGS="$CFLAGS -Werror:CFLAGS="$CFLAGS:' \
		-i configure.in configure || die "sed failed"

	# Fix intltoolize broken file, see upstream #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in || die "sed failed"

	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-2.22.1-interix3.patch

	# Detect where dlopen functions are rather than hardcoding -ldl
	# Fixes build on BSD
	# Bug #271359
	# Gnome bug #584307
	epatch "${FILESDIR}/${P}-dlopen.patch"
	eautoreconf

}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check || die "emake check failed!"

	Xemake -C tests run || die "running tests failed!"
}
