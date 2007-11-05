# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/editor/editor-0.ebuild,v 1.7 2007/10/23 21:45:19 ulm Exp $

EAPI="prefix"

DESCRIPTION="Virtual for editor"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86 ~x86-fbsd ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND="|| ( app-editors/nano
	app-editors/e3
	app-editors/easyedit
	app-editors/elvis
	app-editors/emacs
	app-editors/emacs-cvs
	app-editors/emact
	app-editors/ersatz-emacs
	app-editors/fe
	app-editors/gvim
	app-editors/jasspa-microemacs
	app-editors/jed
	app-editors/joe
	app-editors/jove
	app-editors/le
	app-editors/mg
	app-editors/ne
	app-editors/ng
	app-editors/nvi
	app-editors/qemacs
	app-editors/teco
	app-editors/uemacs-pk
	app-editors/vile
	app-editors/vim
	app-editors/xemacs
	app-editors/zile
	app-misc/mc
	dev-lisp/cmucl
	dev-scheme/mit-scheme
	mail-client/pine
	sys-apps/ed )"

# Packages outside app-editors providing an editor:
#	app-misc/mc: mcedit (#62643)
#	dev-lisp/cmucl: hemlock
#	dev-scheme/mit-scheme: edwin (#193697)
#	mail-client/pine: pico
