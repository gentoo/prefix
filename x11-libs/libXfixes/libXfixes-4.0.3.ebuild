# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXfixes/libXfixes-4.0.3.ebuild,v 1.11 2007/06/24 22:37:03 vapier Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xfixes library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

RDEPEND="x11-libs/libX11
	>=x11-proto/fixesproto-4
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/xextproto"

src_unpack() {
	x-modular_src_unpack
	eautoreconf # need new libtool for interix
}
