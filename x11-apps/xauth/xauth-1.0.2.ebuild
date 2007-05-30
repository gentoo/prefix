# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xauth/xauth-1.0.2.ebuild,v 1.7 2007/05/20 22:03:58 jer Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X authority file utility"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="ipv6"

RDEPEND="x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXext
	x11-libs/libXmu"
DEPEND="${RDEPEND}"

CONFIGURE_OPTIONS="$(use_enable ipv6)"
