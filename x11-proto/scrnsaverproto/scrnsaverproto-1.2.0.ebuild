# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/scrnsaverproto/scrnsaverproto-1.2.0.ebuild,v 1.3 2009/10/26 10:59:10 remi Exp $

EAPI="2"

inherit x-modular

DESCRIPTION="X.Org ScrnSaver protocol headers"

KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="!<x11-libs/libXScrnSaver-1.2"
DEPEND="${RDEPEND}"
