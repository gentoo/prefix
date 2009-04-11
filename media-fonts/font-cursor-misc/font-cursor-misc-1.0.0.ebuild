# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/font-cursor-misc/font-cursor-misc-1.0.0.ebuild,v 1.17 2007/07/15 05:13:09 mr_bones_ Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org cursor font"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
RDEPEND=""
DEPEND="${RDEPEND}
	x11-apps/bdftopcf"
