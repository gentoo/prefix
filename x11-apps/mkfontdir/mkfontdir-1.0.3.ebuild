# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/mkfontdir/mkfontdir-1.0.3.ebuild,v 1.11 2007/08/07 13:23:42 gustavoz Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="create an index of X font files in a directory"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

RDEPEND="x11-apps/mkfontscale"
DEPEND="${RDEPEND}"
