# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/transmission/transmission-1.52.ebuild,v 1.2 2009/05/02 16:47:42 nixnut Exp $

EAPI=2

inherit autotools eutils fdo-mime gnome2-utils

DESCRIPTION="A Fast, Easy and Free BitTorrent client"
HOMEPAGE="http://www.transmissionbt.com"
SRC_URI="http://download.${PN}bt.com/${PN}/files/${P}.tar.bz2"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="gtk libnotify"

RDEPEND=">=dev-libs/openssl-0.9.4
	|| ( >=net-misc/curl-7.16.3[ssl] >=net-misc/curl-7.16.3[gnutls] )
	gtk? ( >=dev-libs/glib-2.15.5
		>=x11-libs/gtk+-2.6
		>=dev-libs/dbus-glib-0.70
		libnotify? ( >=x11-libs/libnotify-0.4.4 ) )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	dev-util/intltool
	dev-util/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.42-solaris-no-utility.patch
	sed -i -e 's:-g -O3 -funroll-loops::g' "${S}"/configure.ac
	eautoreconf
}

src_configure() {
	local myconf="--disable-dependency-tracking --with-wx-config=no"

	econf \
		$(use_enable gtk) \
		$(use_enable libnotify) \
		${myconf}
}

pkg_preinst() {
	gnome2_icon_savelist
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS NEWS
	rm -f "${ED}"/usr/share/${PN}/web/LICENSE
	doinitd "${FILESDIR}"/transmission-daemon
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
