# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/flim/flim-0.ebuild,v 1.4 2007/12/17 07:38:44 ulm Exp $

EAPI="prefix"

DESCRIPTION="Virtual for flim (library for message representation in Emacs)"
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/emacs/"
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND="|| (
		app-emacs/flim
		app-emacs/limit
	)"
