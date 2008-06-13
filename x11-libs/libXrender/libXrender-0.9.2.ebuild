# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXrender/libXrender-0.9.2.ebuild,v 1.12 2007/08/07 13:14:21 gustavoz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xrender library"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

RDEPEND="x11-libs/libX11
		x11-proto/renderproto
		x11-proto/xproto"
DEPEND="${RDEPEND}"
