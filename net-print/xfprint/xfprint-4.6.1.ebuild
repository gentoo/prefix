# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/xfprint/xfprint-4.6.1.ebuild,v 1.2 2009/04/28 10:27:54 ssuominen Exp $

EAPI=1
inherit xfce4

xfce4_core

DESCRIPTION="Frontend for printing, management and job queue."
HOMEPAGE="http://www.xfce.org/projects/xfprint"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="+cups debug"

RDEPEND="app-text/a2ps
	>=dev-libs/glib-2.6:2
	>=x11-libs/gtk+-2.6:2
	>=xfce-base/libxfce4util-${XFCE_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_VERSION}
	>=xfce-base/xfconf-${XFCE_VERSION}
	cups? ( net-print/cups )
	!cups? ( net-print/lprng )"
DEPEND="${RDEPEND}
	dev-util/intltool"

pkg_setup() {
	# - Cups allows you to have both bsdlpr and cups.
	# - Enabling gtk-doc is no use, the documentation
	# has been prebuilt.
	XFCE_CONFIG+=" --enable-bsdlpr
		--disable-gtk-doc $(use_enable cups)"
	DOCS="AUTHORS ChangeLog NEWS README TODO"
}

src_unpack() {
	xfce4_src_unpack
	sed -i -e "/24x24/d" "${S}"/icons/Makefile.in \
		|| die "sed failed"
}
