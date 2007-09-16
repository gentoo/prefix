# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/xemacs-elisp-common.eclass,v 1.1 2007/09/15 07:19:22 graaff Exp $
#
# Copyright 2007 Hans de Graaff <graaff@gentoo.org>
#
# Based on elisp-common.eclass:
# Copyright 2007 Christian Faulhammer <opfer@gentoo.org>
# Copyright 2002-2004 Matthew Kennedy <mkennedy@gentoo.org>
# Copyright 2004-2005 Mamoru Komachi <usata@gentoo.org>
# Copyright 2003 Jeremy Maitin-Shepard <jbms@attbi.com>
# Copyright 2007 Ulrich Mueller <ulm@gentoo.org>
#
# @ECLASS: xemacs-elisp-common.eclass
# @MAINTAINER:
# xemacs@gentoo.org
# @BLURB: XEmacs-related installation utilities
# @DESCRIPTION:
#
# Usually you want to use this eclass for (optional) XEmacs support of
# your package.  This is NOT for GNU Emacs!
#
# Many of the steps here are sometimes done by the build system of your
# package (especially compilation), so this is mainly for standalone elisp
# files you gathered from somewhere else.
#
# When relying on the xemacs USE flag, you need to add
#
#       xemacs? ( virtual/xemacs )
#
# to your DEPEND/RDEPEND line and use the functions provided here to bring
# the files to the correct locations.
#
# .SS
# src_compile() usage:
#
# An elisp file is compiled by the xemacs-elisp-compile() function
# defined here and simply takes the source files as arguments.
#
#       xemacs-elisp-compile *.el || die "xemacs-elisp-compile failed"
#
# Function xemacs-elisp-make-autoload-file() can be used to generate a
# file with autoload definitions for the lisp functions.  It takes a
# list of directories (default: working directory) as its argument.
# Use of this function requires that the elisp source files contain
# magic ";;;###autoload" comments. See the XEmacs Lisp Reference Manual
# (node "Autoload") for a detailed explanation.
#
# .SS
# src_install() usage:
#
# The resulting compiled files (.elc) should be put in a subdirectory of
# /usr/lib/xemacs/site-lisp/ which is named after the first argument
# of elisp-install().  The following parameters are the files to be put in
# that directory.  Usually the subdirectory should be ${PN}, you can choose
# something else, but remember to tell elisp-site-file-install() (see below)
# the change, as it defaults to ${PN}.
#
#       elisp-install ${PN} *.el *.elc || die "elisp-install failed"
#


SITEPACKAGE=/usr/lib/xemacs/site-packages
XEMACS=/usr/bin/xemacs
XEMACS_BATCH_CLEAN="${XEMACS} --batch --no-site-file --no-init-file"

# @FUNCTION: xemacs-elisp-compile
# @USAGE: <list of elisp files>
# @DESCRIPTION:
# Byte-compile elisp files with xemacs
xemacs-elisp-compile () {
	${XEMACS_BATCH_CLEAN} -f batch-byte-compile "$@"
	xemacs-elisp-make-autoload-file "$@"
}

xemacs-elisp-make-autoload-file () {
	${XEMACS_BATCH_CLEAN} \
		-eval "(setq autoload-package-name \"${PN}\")" \
		-eval "(setq generated-autoload-file \"${S}/auto-autoloads.el\")" \
		-l autoload -f batch-update-autoloads "$@"
}

# @FUNCTION: xemacs-elisp-install
# @USAGE: <subdirectory> <list of files>
# @DESCRIPTION:
# Install elisp source and byte-compiled files. All files are installed
# in site-packages in their own directory, indicated by the first
# argument to the function.

xemacs-elisp-install () {
	local subdir="$1"
	shift
	(  # use sub-shell to avoid possible environment polution
		dodir "${SITEPACKAGE}"/lisp/"${subdir}"
		insinto "${SITEPACKAGE}"/lisp/"${subdir}"
		doins "$@"
	) || die "Installing lisp files failed"
}
