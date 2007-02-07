# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/virtual/ghostscript/ghostscript-0.ebuild,v 1.4 2006/08/23 21:27:59 swegener Exp $

EAPI="prefix"

DESCRIPTION="Virtual for Ghostscript"
HOMEPAGE="http://www.ghostscript.com"
SRC_URI=""
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""
DEPEND=""
RDEPEND="|| (
		app-text/ghostscript-gpl
		>=app-text/ghostscript-esp-8
		app-text/ghostscript-gnu
		app-text/ghostscript-esp
	)"
