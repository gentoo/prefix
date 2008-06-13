# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXdamage/libXdamage-1.1.1.ebuild,v 1.11 2007/06/24 22:36:19 vapier Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xdamage library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"

RDEPEND="x11-libs/libX11
	x11-libs/libXfixes
	>=x11-proto/damageproto-1.1
	x11-proto/xproto"
DEPEND="${RDEPEND}"

src_unpack() {
	x-modular_src_unpack
	eautoreconf # need new libtool for interix
}

pkg_postinst() {
	x-modular_pkg_postinst

	ewarn "Compositing managers may stop working."
	ewarn "To fix them, recompile xorg-server."
}
