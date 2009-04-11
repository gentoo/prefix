# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmpd/libmpd-0.16.1.ebuild,v 1.5 2008/12/29 23:17:03 tcunha Exp $

EAPI=1

DESCRIPTION="A library handling connection to a MPD server."
HOMEPAGE="http://gmpcwiki.sarine.nl/index.php/Libmpd"
SRC_URI="http://download.sarine.nl/Programs/gmpc/${PV}/${P}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=dev-libs/glib-2.16:2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README
}
