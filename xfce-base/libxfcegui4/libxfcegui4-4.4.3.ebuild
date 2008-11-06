# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/libxfcegui4/libxfcegui4-4.4.3.ebuild,v 1.1 2008/10/30 22:01:32 angelos Exp $

EAPI="prefix"

inherit xfce44

XFCE_VERSION=4.4.3

xfce44
xfce44_core_package

DESCRIPTION="Unified widgets library"
HOMEPAGE="http://www.xfce.org/projects/libraries"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="debug doc startup-notification"

RDEPEND="x11-libs/libSM
	x11-libs/libX11
	>=x11-libs/gtk+-2.6
	>=xfce-base/libxfce4util-${XFCE_MASTER_VERSION}
	startup-notification? ( x11-libs/startup-notification )"
DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )"

#src_unpack() {
#	unpack ${A}
#	sed -i -e "s:-Werror::g" "${S}"/configure || die "sed failed"
#}

DOCS="AUTHORS ChangeLog NEWS README TODO"
