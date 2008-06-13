# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXp/libXp-1.0.0.ebuild,v 1.16 2007/02/04 18:25:36 joshuabaergen Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular autotools

DESCRIPTION="X.Org Xp library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXau
	x11-proto/printproto"
DEPEND="${RDEPEND}"

src_unpack() {
	x-modular_src_unpack
	eautoreconf # need new libtool for interix
}
