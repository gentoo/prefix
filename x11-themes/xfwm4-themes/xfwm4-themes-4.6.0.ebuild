# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/xfwm4-themes/xfwm4-themes-4.6.0.ebuild,v 1.10 2009/08/25 15:58:15 ssuominen Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Xfce4 window manager themes"
HOMEPAGE="http://www.xfce.org/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=xfce-base/xfwm4-${PV}"
DEPEND=""

RESTRICT="binchecks strip"

pkg_setup() {
	DOCS="AUTHORS ChangeLog README TODO"
}
# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/xfwm4-themes/xfwm4-themes-4.6.0.ebuild,v 1.1 2009/03/10 13:56:15 angelos Exp $

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
