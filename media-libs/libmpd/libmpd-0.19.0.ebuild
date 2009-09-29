# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmpd/libmpd-0.19.0.ebuild,v 1.1 2009/09/27 11:41:40 ssuominen Exp $

EAPI=2

DESCRIPTION="A library handling connections to a MPD server"
HOMEPAGE="http://gmpcwiki.sarine.nl/index.php/Libmpd"
SRC_URI="mirror://sourceforge/musicpd/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=dev-libs/glib-2.16:2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README
}
