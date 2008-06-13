# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXres/libXres-1.0.3.ebuild,v 1.12 2007/08/07 13:15:00 gustavoz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular autotools

DESCRIPTION="X.Org XRes library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/resourceproto"

src_unpack() {
	x-modular_src_unpack
	eautoreconf # need new libtool for interix
}
