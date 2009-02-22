# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/bash-completion.eclass,v 1.21 2009/02/21 20:17:01 darkside Exp $

# @ECLASS: bash-completion.eclass
# @MAINTAINER:
# shell-tools@gentoo.org.
#
# Original author: Aaron Walker <ka0ttic@gentoo.org>
# @BLURB: An Interface for installing contributed bash-completion scripts
# @DESCRIPTION:
# Simple eclass that provides an interface for installing
# contributed (ie not included in bash-completion proper)
# bash-completion scripts.

# @ECLASS-VARIABLE: BASH_COMPLETION_NAME
# @DESCRIPTION:
# Install the completion script with this name (see also dobashcompletion)

EXPORT_FUNCTIONS pkg_postinst

IUSE="bash-completion"

RDEPEND="bash-completion? (	app-admin/eselect )"

# @FUNCTION: dobashcompletion
# @USAGE: < file > [ new_file ]
# @DESCRIPTION:
# First arg, <file>, is required and is the location of the bash-completion
# script to install.  If the variable BASH_COMPLETION_NAME is set in the
# ebuild, dobashcompletion will install <file> as
# /usr/share/bash-completion/$BASH_COMPLETION_NAME. If it is not set,
# dobashcompletion will check if a second arg [new_file] was passed, installing as
# the specified name.  Failing both these checks, dobashcompletion will
# install the file as /usr/share/bash-completion/${PN}.
dobashcompletion() {
	[[ -z "$1" ]] && die "usage: dobashcompletion <file> <new file>"
	[[ -z "${BASH_COMPLETION_NAME}" ]] && BASH_COMPLETION_NAME="${2:-${PN}}"

	if useq bash-completion ; then
		insinto /usr/share/bash-completion
		newins "$1" "${BASH_COMPLETION_NAME}" || die "Failed to install $1"
	fi
}

# @FUNCTION: bash-completion_pkg_postinst
# @DESCRIPTION:
# The bash-completion pkg_postinst function, which is exported
bash-completion_pkg_postinst() {
	if useq bash-completion ; then
		elog "To enable command-line completion for ${PN}, run:"
		elog
		elog "  eselect bashcomp enable ${BASH_COMPLETION_NAME:-${PN}}"
		elog
		elog "to install locally, or"
		elog
		elog "  eselect bashcomp enable --global ${BASH_COMPLETION_NAME:-${PN}}"
		elog
		elog "to install system-wide."
	fi
}
