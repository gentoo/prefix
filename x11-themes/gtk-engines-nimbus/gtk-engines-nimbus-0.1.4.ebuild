# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-nimbus/gtk-engines-nimbus-0.1.4.ebuild,v 1.2 2010/02/03 20:34:31 maekke Exp $

EAPI=2
inherit gnome2-utils autotools

MY_P=nimbus-${PV}

DESCRIPTION="Nimbus GTK+ Engine from Sun JDS"
HOMEPAGE="http://dlc.sun.com/osol/jds/downloads/extras/nimbus/"
SRC_URI="http://dlc.sun.com/osol/jds/downloads/extras/nimbus/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.6:2"
DEPEND="${RDEPEND}
	>=x11-misc/icon-naming-utils-0.8.1
	dev-util/pkgconfig
	dev-util/intltool"

S=${WORKDIR}/${MY_P}

src_prepare() {
	echo light-index.theme.in >> po/POTFILES.skip
	echo dark-index.theme.in >> po/POTFILES.skip

	eautoreconf # required for interix
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--disable-static
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog
}

pkg_preinst() { gnome2_icon_savelist; }
pkg_postinst() { gnome2_icon_cache_update; }
pkg_postrm() { gnome2_icon_cache_update; }
