# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXcomposite/libXcomposite-0.4.1.ebuild,v 1.5 2009/12/15 19:34:56 ranger Exp $

inherit x-modular

DESCRIPTION="X.Org Xcomposite library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

RDEPEND="x11-libs/libX11
	x11-libs/libXfixes
	x11-libs/libXext
	>=x11-proto/compositeproto-0.4
	x11-proto/xproto"
DEPEND="${RDEPEND}
	doc? ( app-text/xmlto )"
