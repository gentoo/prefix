# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/fixesproto/fixesproto-4.1.1.ebuild,v 1.2 2009/10/26 10:29:09 remi Exp $

inherit x-modular

DESCRIPTION="X.Org Fixes protocol headers"

KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND=">=x11-proto/xextproto-7.0.99.1"
DEPEND="${RDEPEND}"
