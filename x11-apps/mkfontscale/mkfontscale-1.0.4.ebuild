# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/mkfontscale/mkfontscale-1.0.4.ebuild,v 1.2 2008/07/17 00:04:14 dberkholz Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="create an index of scalable font files for X"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"

RDEPEND="x11-libs/libfontenc
	=media-libs/freetype-2*"
DEPEND="${RDEPEND}
	x11-proto/xproto"
