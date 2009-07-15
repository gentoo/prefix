# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/lxde-base/lxappearance/lxappearance-0.2.1.ebuild,v 1.2 2009/07/13 17:52:15 vostorga Exp $

EAPI="1"

inherit autotools eutils

DESCRIPTION="LXDE GTK+ theme switcher"
HOMEPAGE="http://lxde.sourceforge.net"
SRC_URI="mirror://sourceforge/lxde/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="x11-libs/gtk+:2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext"

src_unpack() {
	unpack ${A}
	cd "${S}"

	#bug 277651
	epatch "${FILESDIR}"/${P}-intltool.patch

	# Rerun autotools
	einfo "Regenerating autotools files..."
	eautoreconf
}

src_compile() {
	econf --disable-dependency-tracking
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS
}
