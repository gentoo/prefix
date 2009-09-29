# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xset/xset-1.1.0.ebuild,v 1.1 2009/09/28 10:23:30 remi Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org xset application"

KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos ~x64-solaris"
IUSE=""

RDEPEND="x11-libs/libXmu
	x11-libs/libXfontcache"
DEPEND="${RDEPEND}"
