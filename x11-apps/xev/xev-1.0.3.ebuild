# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xev/xev-1.0.3.ebuild,v 1.10 2009/04/16 02:08:23 jer Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="print contents of X events"

KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-winnt"

RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"
