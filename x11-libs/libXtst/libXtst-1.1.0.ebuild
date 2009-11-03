# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXtst/libXtst-1.1.0.ebuild,v 1.2 2009/10/26 09:45:58 remi Exp $

inherit x-modular

DESCRIPTION="X.Org Xtst library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="x11-libs/libX11
	>=x11-libs/libXext-1.0.99.4
	  x11-libs/libXi
	>=x11-proto/recordproto-1.13.99.1
	>=x11-proto/xextproto-7.0.99.3"
DEPEND="${RDEPEND}
	x11-proto/inputproto"
