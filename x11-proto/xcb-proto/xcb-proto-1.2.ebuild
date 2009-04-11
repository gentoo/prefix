# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xcb-proto/xcb-proto-1.2.ebuild,v 1.2 2008/08/03 08:33:58 dberkholz Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X C-language Bindings protocol headers"
HOMEPAGE="http://xcb.freedesktop.org/"
SRC_URI="http://xcb.freedesktop.org/dist/${P}.tar.bz2"
LICENSE="X11"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
RDEPEND=""
DEPEND="${RDEPEND}
	dev-libs/libxml2
	>=dev-lang/python-2.5"
