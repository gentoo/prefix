# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXvMC/libXvMC-1.0.4.ebuild,v 1.13 2009/05/05 07:53:21 ssuominen Exp $

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org XvMC library"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXv
	x11-proto/videoproto
	x11-proto/xproto"
DEPEND="${RDEPEND}"
PDEPEND="app-admin/eselect-xvmc"
