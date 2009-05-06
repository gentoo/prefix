# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libxkbui/libxkbui-1.0.2.ebuild,v 1.10 2009/05/05 07:24:53 ssuominen Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org xkbui library"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND="x11-libs/libXt
	>=x11-libs/libxkbfile-1.0.3
	x11-proto/kbproto"
DEPEND="${RDEPEND}"
