# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/ghostscript/ghostscript-0.ebuild,v 1.7 2009/05/26 05:59:39 pva Exp $

DESCRIPTION="Virtual for Ghostscript"
HOMEPAGE="http://www.ghostscript.com"
SRC_URI=""
LICENSE="as-is"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND=""
RDEPEND="|| (
		app-text/ghostscript-gpl
		app-text/ghostscript-gnu
	)"
