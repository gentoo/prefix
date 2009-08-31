# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/thunar-archive-plugin/thunar-archive-plugin-0.2.4-r1.ebuild,v 1.1 2009/08/24 09:17:21 ssuominen Exp $

inherit xfconf

DESCRIPTION="Thunar archive plugin"
HOMEPAGE="http://www.foo-projects.org/~benny/projects/thunar-archive-plugin"
SRC_URI="mirror://xfce/src/thunar-plugins/${PN}/0.2/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug"

COMMON_DEPEND="xfce-base/thunar"
RDEPEND="${COMMON_DEPEND}
	|| ( app-arch/xarchiver
	app-arch/file-roller
	app-arch/squeeze
	kde-base/ark )"
DEPEND="${COMMON_DEPEND}
	sys-devel/gettext
	dev-util/pkgconfig"

pkg_setup() {
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
	DOCS="AUTHORS ChangeLog NEWS README THANKS"
}
