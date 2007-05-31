# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXv/libXv-1.0.3.ebuild,v 1.7 2007/05/20 21:16:12 jer Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xv library"

KEYWORDS="~amd64 ~ia64 ~x86"

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-proto/videoproto
	x11-proto/xproto"
DEPEND="${RDEPEND}"
