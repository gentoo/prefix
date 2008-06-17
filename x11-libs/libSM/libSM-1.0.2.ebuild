# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libSM/libSM-1.0.2.ebuild,v 1.12 2007/08/07 13:04:51 gustavoz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org SM library"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="ipv6"

RDEPEND="x11-libs/libICE
	x11-libs/xtrans
	x11-proto/xproto"
DEPEND="${RDEPEND}"

CONFIGURE_OPTIONS="$(use_enable ipv6)"
