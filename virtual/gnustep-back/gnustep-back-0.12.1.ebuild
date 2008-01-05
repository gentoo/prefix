# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/gnustep-back/gnustep-back-0.12.1.ebuild,v 1.1 2008/01/03 12:35:29 voyageur Exp $

EAPI="prefix"

DESCRIPTION="Virtual for back-end component for the GNUstep GUI Library"
HOMEPAGE="http://www.gnustep.org"
SRC_URI=""
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-solaris"
RDEPEND="|| (
		~gnustep-base/gnustep-back-art-${PV}
		~gnustep-base/gnustep-back-xlib-${PV}
		~gnustep-base/gnustep-back-cairo-${PV}
	)"
DEPEND=""
