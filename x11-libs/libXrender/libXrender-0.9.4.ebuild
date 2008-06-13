# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXrender/libXrender-0.9.4.ebuild,v 1.6 2007/12/20 07:24:27 opfer Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xrender library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

RDEPEND="x11-libs/libX11
		>=x11-proto/renderproto-0.9.3
		x11-proto/xproto"
DEPEND="${RDEPEND}"

src_unpack() {
	x-modular_src_unpack
	eautoreconf # need new libtool for interix
}
