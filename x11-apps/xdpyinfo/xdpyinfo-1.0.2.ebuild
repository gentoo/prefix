# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xdpyinfo/xdpyinfo-1.0.2.ebuild,v 1.5 2007/05/05 18:20:14 dang Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="display information utility for X"

KEYWORDS="~amd64 ~ia64 ~mips ~x86"

IUSE="dga dmx xinerama"

RDEPEND="x11-libs/libXext
	x11-libs/libX11
	x11-libs/libXtst
	x11-libs/libXxf86vm
	dga? ( x11-libs/libXxf86dga )
	x11-libs/libXxf86misc
	x11-libs/libXi
	x11-libs/libXrender
	xinerama? ( x11-libs/libXinerama )
	dmx? ( x11-libs/libdmx )
	x11-libs/libXp"
DEPEND="${RDEPEND}
	x11-proto/kbproto
	x11-proto/xf86vidmodeproto
	dga? ( x11-proto/xf86dgaproto )
	x11-proto/xf86miscproto
	x11-proto/inputproto
	x11-proto/renderproto
	xinerama? ( x11-proto/xineramaproto )
	dmx? ( x11-proto/dmxproto )
	x11-proto/printproto"

CONFIGURE_OPTIONS="$(use_with dga)
	$(use_with dmx)
	$(use_with xinerama)"
