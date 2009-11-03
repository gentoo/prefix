# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXxf86vm/libXxf86vm-1.1.0.ebuild,v 1.2 2009/10/27 02:54:48 abcd Exp $

inherit x-modular

DESCRIPTION="X.Org Xxf86vm library"

KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"

RDEPEND="
	>=x11-libs/libX11-1.3
	>=x11-libs/libXext-1.1
	>=x11-proto/xf86vidmodeproto-2.3
"
DEPEND="${RDEPEND}
	x11-proto/xproto"
