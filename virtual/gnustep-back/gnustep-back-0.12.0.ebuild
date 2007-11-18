# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/gnustep-back/gnustep-back-0.12.0.ebuild,v 1.8 2007/11/16 15:01:10 beandog Exp $

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
