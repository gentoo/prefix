# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/ghostscript/ghostscript-0.ebuild,v 1.5 2007/07/13 12:37:17 uberlord Exp $

EAPI="prefix"

DESCRIPTION="Virtual for Ghostscript"
HOMEPAGE="http://www.ghostscript.com"
SRC_URI=""
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE=""
DEPEND=""
RDEPEND="|| (
		app-text/ghostscript-gpl
		>=app-text/ghostscript-esp-8
		app-text/ghostscript-gnu
		app-text/ghostscript-esp
	)"
