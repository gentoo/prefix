# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/iceauth/iceauth-1.0.3.ebuild,v 1.5 2009/12/27 17:38:24 josejx Exp $

inherit x-modular

DESCRIPTION="ICE authority file utility"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libICE"
DEPEND="${RDEPEND}"
