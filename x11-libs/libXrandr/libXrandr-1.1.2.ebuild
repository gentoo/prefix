# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-libs/libXrandr/libXrandr-1.1.2.ebuild,v 1.1 2006/10/22 18:04:03 joshuabaergen Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xrandr library"

KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender
	x11-proto/randrproto
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/renderproto"
