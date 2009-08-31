# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-smartbookmark-plugin/xfce4-smartbookmark-plugin-0.4.2.ebuild,v 1.1 2009/08/24 12:13:09 ssuominen Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Xfce panel smart-bookmark plugin"
HOMEPAGE="http://www.xfce.org/"
SRC_URI="mirror://xfce/src/panel-plugins/${PN}/0.4/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug"

COMMON_DEPEND=">=xfce-base/xfce4-panel-4.3.20"
RDEPEND="${COMMON_DEPEND}
	xfce-base/xfce-utils"
DEPEND="${COMMON_DEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

pkg_setup() {
	DOCS="AUTHORS ChangeLog README"
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
}

src_prepare() {
	sed -i -e 's:bugs.debian:bugs.gentoo:g' \
		src/smartbookmark.c || die "sed failed"
	xfconf_src_prepare
}
