# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/xfwm4-themes/xfwm4-themes-4.4.3.ebuild,v 1.6 2008/12/15 04:53:32 jer Exp $

DESCRIPTION="Window manager decorations & themes for Xfce4"
HOMEPAGE="http://www.xfce.org"
SRC_URI="mirror://xfce/xfce-${PV}/src/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RESTRICT="binchecks strip"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
}
# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/xfwm4-themes/xfwm4-themes-4.4.3.ebuild,v 1.1 2008/10/30 22:12:20 angelos Exp $

inherit xfce44

XFCE_VERSION=4.4.2
xfce44

DESCRIPTION="Window manager themes"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
RESTRICT="binchecks strip"

RDEPEND=">=xfce-base/xfwm4-${XFCE_MASTER_VERSION}"
DEPEND=""

DOCS="AUTHORS ChangeLog NEWS README TODO"

xfce44_core_package
