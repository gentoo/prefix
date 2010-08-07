# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/transmission/transmission-2.03.ebuild,v 1.1 2010/07/22 14:20:07 pva Exp $

EAPI=2
inherit eutils fdo-mime gnome2-utils qt4-r2

DESCRIPTION="A Fast, Easy and Free BitTorrent client"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${PN}/files/${P}.tar.bz2"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="gnome gtk libnotify sound qt4"

RDEPEND="
	sys-libs/zlib
	>=dev-libs/libevent-1.4.11
	<dev-libs/libevent-2
	>=dev-libs/openssl-0.9.4
	|| ( >=net-misc/curl-7.16.3[ssl]
		>=net-misc/curl-7.16.3[gnutls] )
	gtk? ( >=dev-libs/glib-2.15.5:2
		>=x11-libs/gtk+-2.12:2
		>=dev-libs/dbus-glib-0.70
		gnome? ( >=gnome-base/gconf-2.20.0 )
		libnotify? ( >=x11-libs/libnotify-0.4.3 )
		sound? ( >=media-libs/libcanberra-0.10 ) )
	qt4? ( x11-libs/qt-gui:4 )"
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2.2.6b
	sys-devel/gettext
	>=dev-util/intltool-0.40
	dev-util/pkgconfig
	sys-apps/sed"

src_prepare() {
	sed -i -e 's:-ggdb3::g' configure || die
}

src_configure() {
	# cli and daemon doesn't have external deps and are enabled by default
	econf \
		--disable-dependency-tracking \
		$(use_enable gtk) \
		$(use gtk && use_enable libnotify) \
		$(use gtk && use_enable sound libcanberra) \
		$(use gtk && use_enable gnome gconf2)

	use qt4 && cd qt && eqmake4 qtr.pro
}

src_compile() {
	emake || die
	use qt4 && cd qt && { emake || die; }
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS NEWS qt/README.txt
	rm -f "${ED}"/usr/share/${PN}/web/LICENSE

	# these are likely outdated for 1.83
	newinitd "${FILESDIR}"/${PN}-daemon.initd.2 ${PN}-daemon || die
	newconfd "${FILESDIR}"/${PN}-daemon.confd.1 ${PN}-daemon || die

	if use qt4; then
		cd qt
		emake INSTALL_ROOT="${ED}/usr" install || die
		make_desktop_entry qtr "Transmission Qt BitTorrent Client" ${PN} \
			"Network;FileTransfer;P2P;Qt"
		use gtk || doicon qt/icons/transmission.png
	fi
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
