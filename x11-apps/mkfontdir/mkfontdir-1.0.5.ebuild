# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/mkfontdir/mkfontdir-1.0.5.ebuild,v 1.5 2009/12/27 17:39:11 josejx Exp $

inherit x-modular

DESCRIPTION="create an index of X font files in a directory"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="x11-apps/mkfontscale"
DEPEND="${RDEPEND}"
