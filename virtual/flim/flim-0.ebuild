# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/flim/flim-0.ebuild,v 1.5 2008/05/29 13:47:44 ulm Exp $

DESCRIPTION="Virtual for flim (library for message representation in Emacs)"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND="|| (
		app-emacs/flim
		app-emacs/limit
	)"
