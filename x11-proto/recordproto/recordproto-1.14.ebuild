# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/recordproto/recordproto-1.14.ebuild,v 1.2 2009/10/26 10:44:32 remi Exp $

inherit x-modular

DESCRIPTION="X.Org Record protocol headers"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="!<x11-libs/libXtst-1.0.99.2"
DEPEND="${RDEPEND}"
