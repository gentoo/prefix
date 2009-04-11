# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/texi2dvi/texi2dvi-0.ebuild,v 1.1 2008/07/07 16:54:10 ulm Exp $

DESCRIPTION="Virtual for texi2dvi (and texi2pdf)"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="sys-apps/texinfo
	virtual/latex-base
	|| (
		dev-texlive/texlive-texinfo
		app-text/tetex
		app-text/ptex
	)"
