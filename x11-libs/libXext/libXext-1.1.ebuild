# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXext/libXext-1.1.ebuild,v 1.2 2009/10/03 15:18:55 scarabeus Exp $

inherit x-modular

DESCRIPTION="X.Org Xext library"

KEYWORDS="~ppc-aix ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND=">=x11-libs/libX11-1.2"
DEPEND="${RDEPEND}
	>=x11-proto/xextproto-7.1
	>=x11-proto/xproto-7.0.16"
