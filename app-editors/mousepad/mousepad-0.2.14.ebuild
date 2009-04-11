# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/mousepad/mousepad-0.2.14.ebuild,v 1.6 2008/12/15 04:49:46 jer Exp $

inherit fdo-mime

DESCRIPTION="A simple GTK+ text editor for Xfce4 (based on leafpad)"
HOMEPAGE="http://www.xfce.org/projects/mousepad"
SRC_URI="mirror://xfce/xfce-4.4.3/src/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="debug nls"

RDEPEND=">=x11-libs/gtk+-2.6:2
	>=xfce-base/libxfce4util-4.4
	>=xfce-base/libxfcegui4-4.4"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	sys-devel/gettext"

src_compile() {
	econf \
		--disable-dependency-tracking \
		$(use_enable debug) \
		$(use_enable nls)
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/mousepad/mousepad-0.2.14.ebuild,v 1.1 2008/10/30 22:15:10 angelos Exp $

inherit xfce44

XFCE_VERSION=4.4.2
xfce44

DESCRIPTION="Text editor"
HOMEPAGE="http://www.xfce.org/projects/mousepad"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=x11-libs/gtk+-2.6
	>=xfce-base/libxfce4util-${XFCE_MASTER_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_MASTER_VERSION}"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

DOCS="AUTHORS ChangeLog NEWS README TODO"

xfce44_core_package
