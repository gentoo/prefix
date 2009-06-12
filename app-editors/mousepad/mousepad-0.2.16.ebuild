# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/mousepad/mousepad-0.2.16.ebuild,v 1.4 2009/06/10 07:34:17 fauli Exp $

inherit xfce4

XFCE_VERSION=4.6.0

xfce4_core

DESCRIPTION="Text editor"
HOMEPAGE="http://www.xfce.org/projects/mousepad/"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=x11-libs/gtk+-2.6:2
	>=xfce-base/libxfce4util-${XFCE_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_VERSION}"
DEPEND="${RDEPEND}
	dev-util/intltool"

DOCS="AUTHORS ChangeLog NEWS README TODO"
# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/mousepad/mousepad-0.2.16.ebuild,v 1.2 2009/03/10 13:54:10 angelos Exp $

inherit xfce44

XFCE_VERSION=4.4.2
xfce44

DESCRIPTION="Text editor"
HOMEPAGE="http://www.xfce.org/projects/mousepad"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=x11-libs/gtk+-2.6
	>=xfce-base/libxfce4util-${XFCE_MASTER_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_MASTER_VERSION}"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

DOCS="AUTHORS ChangeLog NEWS README TODO"

xfce44_core_package
