# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXpm/libXpm-3.5.6.ebuild,v 1.13 2009/05/05 07:11:37 ssuominen Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xpm library"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXext"
DEPEND="${RDEPEND}
	sys-devel/gettext
	x11-proto/xproto"
