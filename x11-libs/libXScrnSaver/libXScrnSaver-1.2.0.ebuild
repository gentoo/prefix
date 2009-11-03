# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXScrnSaver/libXScrnSaver-1.2.0.ebuild,v 1.2 2009/11/01 20:42:35 zmedico Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org XScrnSaver library"
KEYWORDS="~ppc-aix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

COMMON_DEPEND="x11-libs/libX11
	x11-libs/libXext"
RDEPEND="${COMMON_DEPEND}
	!<x11-proto/scrnsaverproto-1.2"
DEPEND="${COMMON_DEPEND}
	>=x11-proto/scrnsaverproto-1.2"
