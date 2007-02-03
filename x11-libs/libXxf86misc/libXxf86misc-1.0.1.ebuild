# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-libs/libXxf86misc/libXxf86misc-1.0.1.ebuild,v 1.9 2006/10/01 17:03:43 dberkholz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xxf86misc library"

KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
RESTRICT="mirror"

RDEPEND="x11-libs/libX11
	x11-libs/libXext"
DEPEND="${RDEPEND}
	x11-proto/xproto
	x11-proto/xf86miscproto"
