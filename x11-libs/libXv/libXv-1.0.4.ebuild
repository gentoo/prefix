# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXv/libXv-1.0.4.ebuild,v 1.1 2008/03/18 04:15:55 dberkholz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xv library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-proto/videoproto
	x11-proto/xproto"
DEPEND="${RDEPEND}"

src_unpack() {
	x-modular_src_unpack
	eautoreconf # need new libtool for interix
}

