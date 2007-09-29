# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/iceauth/iceauth-1.0.2.ebuild,v 1.8 2007/09/28 04:07:55 kumba Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="ICE authority file utility"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"

RDEPEND="x11-libs/libX11
	x11-libs/libICE"
DEPEND="${RDEPEND}"
