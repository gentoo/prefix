# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-xfce/gtk-engines-xfce-2.6.0.ebuild,v 1.11 2009/08/25 16:04:46 ssuominen Exp $

EAPI=2
MY_PN=gtk-xfce-engine
inherit xfconf

DESCRIPTION="GTK+ Xfce4 theme engine"
HOMEPAGE="http://www.xfce.org/"
SRC_URI="mirror://xfce/src/xfce/${MY_PN}/2.6/${MY_PN}-${PV}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.12:2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/${MY_PN}-${PV}

pkg_setup() {
	DOCS="AUTHORS ChangeLog NEWS README"
	XFCONF="--disable-dependency-tracking"
}
