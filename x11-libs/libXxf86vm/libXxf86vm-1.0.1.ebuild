# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXxf86vm/libXxf86vm-1.0.1.ebuild,v 1.11 2007/02/04 18:26:58 joshuabaergen Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular autotools

DESCRIPTION="X.Org Xxf86vm library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

RDEPEND="x11-libs/libX11
	x11-libs/libXext"
DEPEND="${RDEPEND}
	x11-proto/xproto
	x11-proto/xf86vidmodeproto"

src_unpack() {
	x-modular_src_unpack
	eautoreconf # need new libtool for interix
}
