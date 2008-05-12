# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/thunar-archive/thunar-archive-0.2.4-r1.ebuild,v 1.19 2008/05/11 14:08:29 drac Exp $

EAPI="prefix"

inherit xfce44

xfce44
xfce44_goodies_thunar_plugin

DESCRIPTION="Thunar archive plugin"
HOMEPAGE="http://www.foo-projects.org/~benny/projects/thunar-archive-plugin"
SRC_URI="mirror://berlios/xfce-goodies/${MY_P}${COMPRESS}"

KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug"

RDEPEND="|| ( app-arch/xarchiver app-arch/file-roller app-arch/squeeze kde-base/ark )"

DOCS="AUTHORS ChangeLog NEWS README THANKS"
