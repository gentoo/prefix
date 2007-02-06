# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/imake/imake-1.0.2.ebuild,v 1.10 2006/10/11 00:30:31 dberkholz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="C preprocessor interface to the make utility"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
RESTRICT="mirror"

RDEPEND="x11-misc/xorg-cf-files
	!x11-misc/xmkmf"
DEPEND="${RDEPEND}
	x11-proto/xproto"
