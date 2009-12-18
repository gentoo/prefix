# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXdmcp/libXdmcp-1.0.3.ebuild,v 1.4 2009/12/15 19:35:54 ranger Exp $

inherit x-modular

DESCRIPTION="X.Org Xdmcp library"

KEYWORDS="~ppc-aix ~x64-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="x11-proto/xproto"
DEPEND="${RDEPEND}
	>=x11-misc/util-macros-1.1"
