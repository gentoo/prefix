# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/mkfontscale/mkfontscale-1.0.3.ebuild,v 1.6 2007/05/20 22:01:25 jer Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="create an index of scalable font files for X"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"

RDEPEND="x11-libs/libfontenc
	x11-libs/libX11
	=media-libs/freetype-2*"
DEPEND="${RDEPEND}"
