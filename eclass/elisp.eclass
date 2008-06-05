# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/elisp.eclass,v 1.30 2008/06/03 15:48:44 ulm Exp $
#
# Copyright 2002-2003 Matthew Kennedy <mkennedy@gentoo.org>
# Copyright 2003      Jeremy Maitin-Shepard <jbms@attbi.com>
# Copyright 2007      Christian Faulhammer <opfer@gentoo.org>
# Copyright 2007-2008 Ulrich Müller <ulm@gentoo.org>
#
# @ECLASS: elisp.eclass
# @MAINTAINER:
# Feel free to contact the Emacs team through <emacs@gentoo.org> if you
# have problems, suggestions or questions.
# @BLURB: Eclass for Emacs Lisp packages
# @DESCRIPTION:
#
# This eclass sets the site-lisp directory for Emacs-related packages.
#
# Emacs support for other than pure elisp packages is handled by
# elisp-common.eclass where you won't have a dependency on Emacs itself.
# All elisp-* functions are documented there.
#
# If the package's source is a single (in whatever way) compressed elisp
# file with the file name ${P}.el, then this eclass will move ${P}.el to
# ${PN}.el in src_unpack().

# @ECLASS-VARIABLE: DOCS
# @DESCRIPTION:
# DOCS="blah.txt ChangeLog" is automatically used to install the given
# files by dodoc in src_install().

# @ECLASS-VARIABLE: NEED_EMACS
# @DESCRIPTION:
# If you need anything different from Emacs 21, use the NEED_EMACS
# variable before inheriting elisp.eclass.  Set it to the major version
# your package uses and the dependency will be adjusted.

inherit elisp-common versionator

VERSION=${NEED_EMACS:-21}
DEPEND=">=virtual/emacs-${VERSION}"
RDEPEND=">=virtual/emacs-${VERSION}"
IUSE=""

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
	if [ -f ${P}.el ]; then
		mv ${P}.el ${PN}.el || die "mv ${P}.el ${PN}.el failed"
	fi
}

elisp_src_compile() {
	elisp-compile *.el || die "elisp-compile failed"
}

elisp_src_install() {
	elisp-install ${PN} *.el *.elc || die "elisp-install failed"
	elisp-site-file-install "${FILESDIR}/${SITEFILE}" \
		|| die "elisp-site-file-install failed"
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

EXPORT_FUNCTIONS \
	src_unpack src_compile src_install \
	pkg_setup pkg_postinst pkg_postrm
