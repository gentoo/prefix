# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-appfinder/xfce4-appfinder-4.4.2.ebuild,v 1.7 2007/12/17 18:48:24 jer Exp $

EAPI="prefix"

inherit xfce44

XFCE_VERSION=4.4.2
xfce44

DESCRIPTION="Application finder"
HOMEPAGE="http://www.xfce.org/projects/xfce4-appfinder"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=dev-libs/glib-2.6
	>=x11-libs/gtk+-2.6
	>=xfce-base/libxfce4util-${XFCE_MASTER_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_MASTER_VERSION}"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

DOCS="AUTHORS BUGS ChangeLog NEWS README TODO"

xfce44_core_package
