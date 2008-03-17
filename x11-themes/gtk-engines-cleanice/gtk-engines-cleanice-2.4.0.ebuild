# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-cleanice/gtk-engines-cleanice-2.4.0.ebuild,v 1.9 2006/10/09 17:50:29 the_paya Exp $

EAPI="prefix"

inherit autotools

DESCRIPTION="GTK+2 Cleanice Theme Engine"
HOMEPAGE="http://sourceforge.net/projects/elysium-project/"
SRC_URI="mirror://sourceforge/elysium-project/${P}.tar.gz"

KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux"
LICENSE="GPL-2"
IUSE="static"
SLOT="2"

RDEPEND=">=x11-libs/gtk+-2.4
	>=dev-libs/glib-2"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"

	eautoreconf # need new libtool for interix
}

src_compile() {
	local myconf="$(use_enable static)"

	econf $myconf || die "Configuration failed"
	emake || die "Compilation failed"
}

src_install() {
	make DESTDIR="${D}" install || die "Installation failed"

	# Install sample theme
	insinto /usr/share/themes/CleanIce/gtk-2.0
	newins ${FILESDIR}/cleanice-2-gtkrc gtkrc

	dodoc AUTHORS ChangeLog README
}
