# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/libxfce4util/libxfce4util-4.4.2.ebuild,v 1.8 2007/12/17 18:33:33 jer Exp $

EAPI="prefix"

inherit xfce44

XFCE_VERSION=4.4.2
xfce44

DESCRIPTION="Basic utilities library"
HOMEPAGE="http://www.xfce.org/projects/libraries"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="debug doc"

RDEPEND=">=dev-libs/glib-2.6"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( dev-util/gtk-doc )"

DOCS="AUTHORS ChangeLog NEWS README THANKS TODO"

xfce44_core_package
