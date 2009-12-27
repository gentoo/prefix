# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXpm/libXpm-3.5.8.ebuild,v 1.6 2009/12/26 20:44:51 solar Exp $

inherit x-modular

DESCRIPTION="X.Org Xpm library"

KEYWORDS="~ppc-aix ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="nls"

RDEPEND="x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXext"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	x11-proto/xproto"

src_unpack() {
	PATCHES="${FILESDIR}"/${PN}-3.5.7-winnt.patch
	x-modular_src_unpack
}
