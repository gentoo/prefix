# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/gnustep-back/gnustep-back-0.16.0.ebuild,v 1.4 2009/07/19 13:22:59 nixnut Exp $

DESCRIPTION="Virtual for back-end component for the GNUstep GUI Library"
HOMEPAGE="http://www.gnustep.org"
SRC_URI=""
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
RDEPEND="|| (
		~gnustep-base/gnustep-back-art-${PV}
		~gnustep-base/gnustep-back-xlib-${PV}
		~gnustep-base/gnustep-back-cairo-${PV}
	)"
DEPEND=""
