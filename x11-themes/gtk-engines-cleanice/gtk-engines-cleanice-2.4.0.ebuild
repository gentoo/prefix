# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-cleanice/gtk-engines-cleanice-2.4.0.ebuild,v 1.10 2008/03/21 12:40:54 drac Exp $

inherit autotools

DESCRIPTION="GTK+ CleanIce Theme Engine"
HOMEPAGE="http://sourceforge.net/projects/elysium-project"
SRC_URI="mirror://sourceforge/elysium-project/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.4"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"

	eautoreconf # need new libtool for interix
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	insinto /usr/share/themes/CleanIce/gtk-2.0
	newins "${FILESDIR}"/cleanice-2-gtkrc gtkrc
	dodoc AUTHORS ChangeLog README
}
