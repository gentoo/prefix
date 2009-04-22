# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/xfprint/xfprint-4.6.1.ebuild,v 1.1 2009/04/21 04:27:23 darkside Exp $

EAPI="1"

inherit xfce4

xfce4_core

DESCRIPTION="Frontend for printing, management and job queue."
HOMEPAGE="http://www.xfce.org/projects/xfprint"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="cups doc debug"

RDEPEND="app-text/a2ps
	>=dev-libs/glib-2.6:2
	>=x11-libs/gtk+-2.6:2
	>=xfce-base/libxfce4util-${XFCE_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_VERSION}
	>=xfce-base/xfconf-${XFCE_VERSION}
	cups? ( net-print/cups )
	!cups? ( net-print/lprng )"
DEPEND="${RDEPEND}
	dev-util/intltool
	doc? ( dev-util/gtk-doc )"

pkg_setup() {
	use cups || XFCE_CONFIG+=" --enable-bsdlpr"
	use cups && XFCE_CONFIG+=" --enable-cups"
	XFCE_CONFIG+=" $(use_enable doc gtk-doc)"
}

src_unpack() {
	xfce4_src_unpack
	sed -i -e "/24x24/d" "${S}"/icons/Makefile.in
}

DOCS="AUTHORS ChangeLog NEWS README TODO"
