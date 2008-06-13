# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/tex-base/tex-base-0.ebuild,v 1.2 2008/02/12 20:03:17 opfer Exp $

EAPI="prefix"

DESCRIPTION="Virtual for basic TeX binaries (tex, kpathsea)"
HOMEPAGE="http://www.ctan.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND="|| (
		app-text/texlive-core
		app-text/tetex
		app-text/ptex
	)"
