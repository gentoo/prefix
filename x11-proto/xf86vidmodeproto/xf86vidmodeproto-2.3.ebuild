# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xf86vidmodeproto/xf86vidmodeproto-2.3.ebuild,v 1.3 2009/10/26 10:46:28 remi Exp $

EAPI="2"

inherit x-modular

DESCRIPTION="X.Org XF86VidMode protocol headers"

KEYWORDS="~ppc-aix ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="!<x11-libs/libXxf86vm-1.0.99.1"
DEPEND="${RDEPEND}"
