# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/orage/orage-4.5.14.0.ebuild,v 1.3 2009/02/04 18:45:02 angelos Exp $

EAPI="prefix"

inherit autotools eutils gnome2-utils

DESCRIPTION="Calendar suite for Xfce4"
HOMEPAGE="http://www.kolumbus.fi/~w408237/orage"
SRC_URI="http://www.kolumbus.fi/~w408237/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
# This package is waiting for alpha/beta/rc of Xfce 4.6, so please
# don't mark it stable.
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="dbus debug libnotify"

RDEPEND=">=dev-libs/glib-2.6
	>=x11-libs/gtk+-2.6
	>=xfce-base/libxfce4util-4.4
	>=xfce-base/libxfcegui4-4.4
	>=xfce-base/xfce4-panel-4.4
	dbus? ( dev-libs/dbus-glib )
	libnotify? ( x11-libs/libnotify )
	x86-interix? ( dev-util/xfce4-dev-tools )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	dev-util/xfce4-dev-tools
	sys-devel/gettext"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-bsd.patch

	# remove -I m4, there's no m4 dir
	sed -i -e "/^ACLOCAL_AMFLAGS/d" Makefile.am
	AT_M4DIR="/usr/share/xfce4/dev-tools/m4macros" eautoreconf

	# Patch needed for Solaris. Took from
	# http://foo-projects.org/pipermail/xfce/2008-July/023569.html
	if [[ ${CHOST} == *-solaris* ]] ; then
		epatch "${FILESDIR}/${PN}-4.5.14.0-solaris-parameters.c.patch"
		epatch "${FILESDIR}/${PN}-4.5.14.0-solaris-configure.in.patch"
	fi

	epatch "${FILESDIR}"/${P}-interix.patch

	use x86-interix && NOCONFIGURE=yes xdt-autogen # need new libtool for interix
}

src_compile() {
	econf $(use_enable dbus) \
		$(use_enable debug) \
		$(use_enable libnotify)
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	gnome2_icon_cache_update
	elog "There is no migration support from 4.4 to 4.5 so you need to copy Orage files by hand."
}

pkg_postrm() {
	gnome2_icon_cache_update
}

