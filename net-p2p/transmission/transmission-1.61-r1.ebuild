# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/transmission/transmission-1.61-r1.ebuild,v 1.1 2009/05/12 23:21:40 ssuominen Exp $

EAPI=2
inherit autotools fdo-mime gnome2-utils qt4

DESCRIPTION="A Fast, Easy and Free BitTorrent client"
HOMEPAGE="http://www.transmissionbt.com"
SRC_URI="http://download.${PN}bt.com/${PN}/files/${P}.tar.bz2"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="gtk libnotify qt4"

RDEPEND=">=dev-libs/openssl-0.9.4
	|| ( >=net-misc/curl-7.16.3[ssl] >=net-misc/curl-7.16.3[gnutls] )
	gtk? ( >=dev-libs/glib-2.15.5:2
		>=x11-libs/gtk+-2.6:2
		>=dev-libs/dbus-glib-0.70
		libnotify? ( >=x11-libs/libnotify-0.4.3 ) )
	qt4? ( x11-libs/qt-gui:4 )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	dev-util/intltool
	dev-util/pkgconfig
	sys-apps/sed"

src_prepare() {
	sed -i -e 's:-g -O3 -funroll-loops::g' configure.ac || die "sed failed"
	eautoreconf
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable gtk) \
		$(use_enable libnotify)

	if use qt4; then
		cd qt
		eqmake4 qtr.pro
	fi
}

src_compile() {
	emake || die "emake failed"

	if use qt4; then
		cd qt
		emake || die "emake failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS NEWS
	rm -f "${ED}"/usr/share/${PN}/web/LICENSE

	newinitd "${FILESDIR}"/${PN}-daemon.initd ${PN}-daemon
	newconfd "${FILESDIR}"/${PN}-daemon.confd ${PN}-daemon

	if use qt4; then
		cd qt
		emake INSTALL_ROOT="${D}/usr" install || die "emake install failed"
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
