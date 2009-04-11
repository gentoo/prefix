# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/xfprint/xfprint-4.4.3.ebuild,v 1.7 2008/12/15 04:51:29 jer Exp $

EAPI=1

inherit eutils

DESCRIPTION="GTK+ and Xfce4 frontend for printing, management and job queue."
HOMEPAGE="http://www.xfce.org/projects/xfprint"
SRC_URI="mirror://xfce/xfce-${PV}/src/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="cups debug doc"

RDEPEND="app-text/a2ps
	>=dev-libs/glib-2.6:2
	>=x11-libs/gtk+-2.6:2
	>=xfce-base/libxfce4mcs-4.4
	>=xfce-base/libxfce4util-4.4
	>=xfce-base/libxfcegui4-4.4
	>=xfce-base/xfce-mcs-manager-4.4
	cups? ( net-print/cups )
	!cups? ( net-print/lprng )"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/pkgconfig
	sys-devel/gettext
	doc? ( dev-util/gtk-doc )"

src_unpack() {
	unpack ${A}
	sed -i -e "/24x24/d" "${S}"/icons/Makefile.in
}

src_compile() {
	local myconf="--enable-bsdlpr"
	use cups && myconf="--enable-cups"

	econf --disable-dependency-tracking \
		$(use_enable debug) \
		$(use_enable doc gtk-doc) \
		${myconf}

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
}
