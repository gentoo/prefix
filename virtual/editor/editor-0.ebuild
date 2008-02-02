# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/editor/editor-0.ebuild,v 1.13 2008/02/01 14:07:13 ulm Exp $

EAPI="prefix"

DESCRIPTION="Virtual for editor"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~ppc-aix ~x86-fbsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

# Add a package to RDEPEND only if the editor:
# - can edit ordinary text files,
# - works on the console.

DEPEND=""
RDEPEND="|| ( app-editors/nano
	app-editors/dav
	app-editors/e3
	app-editors/easyedit
	app-editors/elvis
	app-editors/emacs
	app-editors/emacs-cvs
	app-editors/emact
	app-editors/ersatz-emacs
	app-editors/fe
	app-editors/geresh
	app-editors/gvim
	app-editors/jasspa-microemacs
	app-editors/jed
	app-editors/joe
	app-editors/jove
	app-editors/le
	app-editors/levee
	app-editors/lpe
	app-editors/mg
	app-editors/ne
	app-editors/ng
	app-editors/nvi
	app-editors/qe
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
