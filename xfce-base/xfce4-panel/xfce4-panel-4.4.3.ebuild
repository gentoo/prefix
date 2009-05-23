# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfce4-panel/xfce4-panel-4.4.3.ebuild,v 1.7 2009/05/21 20:09:01 angelos Exp $

inherit xfce44

XFCE_VERSION=4.4.3

xfce44
xfce44_core_package

DESCRIPTION="Panel"
HOMEPAGE="http://www.xfce.org/projects/xfce4-panel"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
LICENSE="GPL-2 LGPL-2"
IUSE="debug doc startup-notification"

RDEPEND="x11-libs/libX11
	x11-libs/libSM
	>=x11-libs/gtk+-2.6
	>=xfce-base/libxfce4util-${XFCE_MASTER_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_MASTER_VERSION}
	>=xfce-base/xfce-mcs-manager-${XFCE_MASTER_VERSION}
	startup-notification? ( x11-libs/startup-notification )"
DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )"

DOCS="AUTHORS ChangeLog HACKING NEWS README README.Plugins"
