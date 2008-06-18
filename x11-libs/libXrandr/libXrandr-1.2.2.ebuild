# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXrandr/libXrandr-1.2.2.ebuild,v 1.6 2007/12/16 17:51:38 corsair Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular autotools

DESCRIPTION="X.Org Xrandr library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender
	>=x11-proto/randrproto-1.2
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/renderproto"

src_unpack() {
	x-modular_src_unpack
	eautoreconf # need new libtool for interix
}
