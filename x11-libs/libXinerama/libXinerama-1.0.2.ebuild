# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXinerama/libXinerama-1.0.2.ebuild,v 1.11 2007/08/07 13:12:10 gustavoz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xinerama library"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"

RDEPEND="x11-libs/libX11
	x11-libs/libXext"
DEPEND="${RDEPEND}
	x11-proto/xineramaproto"
