# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xhost/xhost-1.0.3.ebuild,v 1.4 2009/12/15 19:14:54 ranger Exp $

inherit x-modular

DESCRIPTION="Controls host and/or user access to a running X server."

KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="ipv6"

RDEPEND="x11-libs/libX11
	x11-libs/libXmu
	x11-libs/libXau"
DEPEND="${RDEPEND}"

pkg_setup() {
	CONFIGURE_OPTIONS="$(use_enable ipv6)"
}

src_unpack() {
	PATCHES="${FILESDIR}"/${PN}-1.0.2-winnt.patch
	x-modular_src_unpack
}
