# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXres/libXres-1.0.3.ebuild,v 1.5 2007/04/29 05:53:40 ticho Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org XRes library"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/resourceproto"
