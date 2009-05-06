# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/mkfontscale/mkfontscale-1.0.3.ebuild,v 1.14 2009/05/05 07:34:41 fauli Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="create an index of scalable font files for X"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""
RDEPEND="x11-libs/libfontenc
	=media-libs/freetype-2*"
DEPEND="${RDEPEND}
	x11-proto/xproto"
