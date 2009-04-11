# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-appfinder/xfce4-appfinder-4.4.3.ebuild,v 1.6 2008/12/15 05:02:47 jer Exp $

EAPI=1

inherit xfce44

XFCE_VERSION=4.4.3

xfce44
xfce44_core_package

DESCRIPTION="Application finder"
HOMEPAGE="http://www.xfce.org/projects/xfce4-appfinder"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="debug nls"

RDEPEND=">=dev-libs/glib-2.6:2
	>=x11-libs/gtk+-2.6:2
	>=xfce-base/libxfce4util-${XFCE_MASTER_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_MASTER_VERSION}"
DEPEND="${RDEPEND}
	dev-util/intltool"

DOCS="AUTHORS BUGS ChangeLog NEWS README TODO"
