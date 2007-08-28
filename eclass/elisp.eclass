# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/elisp.eclass,v 1.22 2007/08/27 19:41:03 ulm Exp $
#
# Copyright 2007 Christian Faulhammer <opfer@gentoo.org>
# Copyright 2002-2003 Matthew Kennedy <mkennedy@gentoo.org>
# Copyright 2003 Jeremy Maitin-Shepard <jbms@attbi.com>
# Copyright 2007 Ulrich Mueller <ulm@gentoo.org>
#
# @ECLASS: elisp.eclass
# @MAINTAINER:
# emacs@gentoo.org
# @BLURB: Eclass for Emacs Lisp packages
# @DESCRIPTION:
#
# This eclass sets the site-lisp directory for Emacs-related packages.
#
# Emacs support for other than pure elisp packages is handled by
# elisp-common.eclass where you won't have a dependency on Emacs itself.
# All elisp-* functions are documented there.
#
# Setting SIMPLE_ELISP=t in an ebuild means, that the package's source
# is a single (in whatever way) compressed elisp file with the file name
# ${PN}-${PV}.  This eclass will then redefine ${S}, and move
# ${PN}-${PV}.el to ${PN}.el in src_unpack().
#
# DOCS="blah.txt ChangeLog" is automatically used to install the given
# files by dodoc in src_install().
#
# If you need anything different from Emacs 21, use the NEED_EMACS
# variable before inheriting elisp.eclass.  Set it to the major version
# your package uses and the dependency will be adjusted.

inherit elisp-common versionator

VERSION=${NEED_EMACS:-21}
DEPEND=">=virtual/emacs-${VERSION}"
RDEPEND=">=virtual/emacs-${VERSION}"
IUSE=""

if [ "${SIMPLE_ELISP}" = 't' ]; then
	S="${WORKDIR}"
fi

elisp_pkg_setup() {
	local emacs_version="$(elisp-emacs-version)"
	if ! version_is_at_least "${VERSION}" "${emacs_version}"; then
		eerror "This package needs at least Emacs ${VERSION}."
		eerror "Use \"eselect emacs\" to select the active version."
		die "Emacs version ${emacs_version} is too low."
	fi
}

elisp_src_unpack() {
	unpack ${A}
	if [ "${SIMPLE_ELISP}" = 't' ]; then
		cd "${S}" && mv ${P}.el ${PN}.el
	fi
}

elisp_src_compile() {
	elisp-compile *.el || die "elisp-compile failed"
}

elisp_src_install() {
	elisp-install ${PN} *.el *.elc
	elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	if [ -n "${DOCS}" ]; then
		dodoc ${DOCS} || die "dodoc failed"
	fi
}

elisp_pkg_postinst() {
	elisp-site-regen
}

elisp_pkg_postrm() {
	elisp-site-regen
}

EXPORT_FUNCTIONS src_unpack src_compile src_install
EXPORT_FUNCTIONS pkg_setup pkg_postinst pkg_postrm
