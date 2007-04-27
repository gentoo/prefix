# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/subversion.eclass,v 1.42 2007/04/23 18:55:15 cardoe Exp $

## --------------------------------------------------------------------------- #
# Author: Akinori Hattori <hattya@gentoo.org>
#
# The subversion eclass is written to fetch the software sources from
# subversion repositories like the cvs eclass.
#
#
# Description:
#   If you use this eclass, the ${S} is ${WORKDIR}/${P}.
#   It is necessary to define the ESVN_REPO_URI variable at least.
#
## --------------------------------------------------------------------------- #

inherit eutils

ESVN="subversion.eclass"

EXPORT_FUNCTIONS src_unpack

DESCRIPTION="Based on the ${ECLASS} eclass"


## -- add subversion in DEPEND
#
DEPEND="dev-util/subversion"


## -- ESVN_STORE_DIR:  subversion sources store directory
#
ESVN_STORE_DIR="${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}/svn-src"


## -- ESVN_FETCH_CMD:  subversion fetch command
#
ESVN_FETCH_CMD="svn checkout"

## -- ESVN_UPDATE_CMD:  subversion update command
#
ESVN_UPDATE_CMD="svn update"


## -- ESVN_OPTIONS:
#
# the options passed to checkout or update.
#
: ESVN_OPTIONS=${ESVN_OPTIONS:=}


## -- ESVN_REPO_URI:  repository uri
#
# e.g. http://foo/trunk, svn://bar/trunk
#
# supported protocols:
#   http://
#   https://
#   svn://
#   svn+ssh://
#
: ESVN_REPO_URI=${ESVN_REPO_URI:=}


## -- ESVN_PROJECT:  project name of your ebuild (= name space)
#
# subversion eclass will check out the subversion repository like:
#
#   ${ESVN_STORE_DIR}/${ESVN_PROJECT}/${ESVN_REPO_URI##*/}
#
# so if you define ESVN_REPO_URI as http://svn.collab.net/repo/svn/trunk or
# http://svn.collab.net/repo/svn/trunk/. and PN is subversion-svn.
# it will check out like:
#
#   ${ESVN_STORE_DIR}/subversion/trunk
#
# this is not used in order to declare the name of the upstream project.
# so that you can declare this like:
#
#   # jakarta commons-loggin
#   ESVN_PROJECT=commons/logging
#
# default: ${PN/-svn}.
#
: ESVN_PROJECT=${ESVN_PROJECT:=${PN/-svn}}


## -- ESVN_BOOTSTRAP:
#
# bootstrap script or command like autogen.sh or etc..
#
: ESVN_BOOTSTRAP=${ESVN_BOOTSTRAP:=}


## -- ESVN_PATCHES:
#
# subversion eclass can apply pathces in subversion_bootstrap().
# you can use regexp in this valiable like *.diff or *.patch or etc.
# NOTE: this patches will apply before eval ESVN_BOOTSTRAP.
#
# the process of applying the patch is:
#   1. just epatch it, if the patch exists in the path.
#   2. scan it under FILESDIR and epatch it, if the patch exists in FILESDIR.
#   3. die.
#
: ESVN_PATCHES=${ESVN_PATCHES:=}


## -- ESVN_RESTRICT:
#
# this should be a space delimited list of subversion eclass features to
# restrict.
#   export)
#     don't export the working copy to S.
#
: ESVN_RESTRICT=${ESVN_RESTRICT:=}


## -- subversion_fetch() ----------------------------------------------------- #
#
# @param $1 - a repository URI. default is the ESVN_REPO_URI.
# @param $2 - a check out path in S.
#
function subversion_fetch() {

	local repo_uri="$(subversion__get_repository_uri "${1}")"
	local S_dest="${2}"

	# check for the protocol
	local protocol="${repo_uri%%:*}"

	case "${protocol}" in
		http|https)
			if built_with_use dev-util/subversion nowebdav; then
				echo
				eerror "In order to emerge this package, you need to"
				eerror "re-emerge subversion with USE=-nowebdav"
				echo
				die "${ESVN}: please run 'USE=-nowebdav emerge subversion'"
			fi
			;;
		svn|svn+ssh)
			;;
		*)
			die "${ESVN}: fetch from "${protocol}" is not yet implemented."
			;;
	esac

	# every time
	addread "/etc/subversion"
	addwrite "${ESVN_STORE_DIR}"

	if [[ ! -d "${ESVN_STORE_DIR}" ]]; then
		debug-print "${FUNCNAME}: initial checkout. creating subversion directory"
		mkdir -p "${ESVN_STORE_DIR}" || die "${ESVN}: can't mkdir ${ESVN_STORE_DIR}."
	fi

	cd "${ESVN_STORE_DIR}" || die "${ESVN}: can't chdir to ${ESVN_STORE_DIR}"

	local wc_path="$(subversion__get_wc_path "${repo_uri}")"
	local options="${ESVN_OPTIONS} --config-dir ${ESVN_STORE_DIR}/.subversion"

	debug-print "${FUNCNAME}: wc_path = \"${wc_path}\""
	debug-print "${FUNCNAME}: ESVN_OPTIONS = \"${ESVN_OPTIONS}\""
	debug-print "${FUNCNAME}: options = \"${options}\""

	if [[ ! -d "${wc_path}/.svn" ]]; then
		# first check out
		einfo "subversion check out start -->"
		einfo "     repository: ${repo_uri}"

		debug-print "${FUNCNAME}: ${ESVN_FETCH_CMD} ${options} ${repo_uri}"

		mkdir -p "${ESVN_PROJECT}" || die "${ESVN}: can't mkdir ${ESVN_PROJECT}."
		cd "${ESVN_PROJECT}" || die "${ESVN}: can't chdir to ${ESVN_PROJECT}"
		${ESVN_FETCH_CMD} ${options} "${repo_uri}" || die "${ESVN}: can't fetch from ${repo_uri}."

	else
		subversion_wc_info "${repo_uri}" || die "${ESVN}: unknown problem occurred while accessing working copy."

		if [ "${ESVN_WC_URL}" != "$(subversion__get_repository_uri "${repo_uri}" 1)" ]; then
			die "${ESVN}: ESVN_REPO_URI (or specified URI) and working copy's URL are not matched."
		fi

		# update working copy
		einfo "subversion update start -->"
		einfo "     repository: ${repo_uri}"

		debug-print "${FUNCNAME}: ${ESVN_UPDATE_CMD} ${options}"

		cd "${wc_path}" || die "${ESVN}: can't chdir to ${wc_path}"
		${ESVN_UPDATE_CMD} ${options} || die "${ESVN}: can't update from ${repo_uri}."

	fi

	einfo "   working copy: ${wc_path}"

	if ! has "export" ${ESVN_RESTRICT}; then
		cd "${wc_path}" || die "${ESVN}: can't chdir to ${wc_path}"

		local S="${S}/${S_dest}"

		# export to the ${WORKDIR}
		#*  "svn export" has a bug.  see http://bugs.gentoo.org/119236
		#* svn export . "${S}" || die "${ESVN}: can't export to ${S}."
		rsync -rlpgo --exclude=".svn/" . "${S}" || die "${ESVN}: can't export to ${S}."
	fi

	echo

}


## -- subversion_bootstrap() ------------------------------------------------ #
#
function subversion_bootstrap() {

	if has "export" ${ESVN_RESTRICT}; then
		return
	fi

	cd "${S}"

	if [[ -n "${ESVN_PATCHES}" ]]; then
		einfo "apply patches -->"

		local p=

		for p in ${ESVN_PATCHES}; do
			if [[ -f "${p}" ]]; then
				epatch "${p}"

			else
				local q=

				for q in ${FILESDIR}/${p}; do
					if [[ -f "${q}" ]]; then
						epatch "${q}"

					else
						die "${ESVN}; ${p} is not found"

					fi
				done
			fi
		done

		echo

	fi

	if [[ -n "${ESVN_BOOTSTRAP}" ]]; then
		einfo "begin bootstrap -->"

		if [[ -f "${ESVN_BOOTSTRAP}" && -x "${ESVN_BOOTSTRAP}" ]]; then
			einfo "   bootstrap with a file: ${ESVN_BOOTSTRAP}"
			eval "./${ESVN_BOOTSTRAP}" || die "${ESVN}: can't execute ESVN_BOOTSTRAP."

		else
			einfo "   bootstrap with commands: ${ESVN_BOOTSTRAP}"
			eval "${ESVN_BOOTSTRAP}" || die "${ESVN}: can't eval ESVN_BOOTSTRAP."

		fi
	fi

}


## -- subversion_src_unpack() ------------------------------------------------ #
#
function subversion_src_unpack() {

	subversion_fetch     || die "${ESVN}: unknown problem occurred in subversion_fetch."
	subversion_bootstrap || die "${ESVN}: unknown problem occurred in subversion_bootstrap."

}


## -- subversion_wc_info() --------------------------------------------------- #
#
# @param $1 - repository URI. default is ESVN_REPO_URI.
#
function subversion_wc_info() {

	local repo_uri="$(subversion__get_repository_uri "${1}")"
	local wc_path="$(subversion__get_wc_path "${repo_uri}")"

	debug-print "${FUNCNAME}: repo_uri = ${repo_uri}"
	debug-print "${FUNCNAME}: wc_path = ${wc_path}"

	if [[ ! -e "${wc_path}" ]]; then
		return 1
	fi

	local k

	for k in url revision; do
		export ESVN_WC_$(subversion__to_upper_case "${k}")="$(subversion__svn_info "${wc_path}" "${k}")"
	done

}


## -- Private Functions


## -- subversion__svn_info() ------------------------------------------------- #
#
# @param $1 - a target.
# @param $2 - a key name.
#
function subversion__svn_info() {

	local target="${1}"
	local key="${2}"

	env LC_ALL=C svn info "${target}" | grep -i "^${key}" | cut -d" " -f2-

}


## -- subversion__get_repository_uri() --------------------------------------- #
#
# @param $1 - a repository URI.
# @param $2 - a peg revision is deleted from a return value if this is
#             specified.
#
function subversion__get_repository_uri() {

	local repo_uri="${1:-${ESVN_REPO_URI}}"
	local remove_peg_revision="${2}"

	debug-print "${FUNCNAME}: repo_uri = ${repo_uri}"
	debug-print "${FUNCNAME}: remove_peg_revision = ${remove_peg_revision}"

	if [[ -z "${repo_uri}" ]]; then
		die "${ESVN}: ESVN_REPO_URI (or specified URI) is empty."
	fi

	# delete trailing slash
	if [[ -z "${repo_uri##*/}" ]]; then
		repo_uri="${repo_uri%/}"
	fi

	if [[ -n "${remove_peg_revision}" ]]; then
		if subversion__has_peg_revision "${repo_uri}"; then
			repo_uri="${repo_uri%@*}"

			debug-print "${FUNCNAME}: repo_uri has a peg revision"
			debug-print "${FUNCNAME}: repo_uri = ${repo_uri}"
		fi
	fi

	echo "${repo_uri}"

}


## -- subversion__get_wc_path() ---------------------------------------------- #
#
# @param $1 - a repository URI.
#
function subversion__get_wc_path() {

	local repo_uri="$(subversion__get_repository_uri "${1}" 1)"

	debug-print "${FUNCNAME}: repo_uri = ${repo_uri}"

	echo "${ESVN_STORE_DIR}/${ESVN_PROJECT}/${repo_uri##*/}"

}


## -- subversion__has_peg_revision() ----------------------------------------- #
#
# @param $1 - a repository URI.
#
function subversion__has_peg_revision() {

	local repo_uri="${1}"

	debug-print "${FUNCNAME}: repo_uri = ${repo_uri}"

	# repo_uri has peg revision ?
	if [[ "${repo_uri}" != *@* ]]; then
		debug-print "${FUNCNAME}: repo_uri does not have a peg revision."
		return 1
	fi

	local peg_rev="${repo_uri##*@}"

	case "$(subversion__to_upper_case "${peg_rev}")" in
		[[:digit:]]*)
			# NUMBER
			;;
		HEAD|BASE|COMMITED|PREV)
			;;
		{[^}]*})
			# DATE
			;;
		*)
			debug-print "${FUNCNAME}: repo_uri does not have a peg revision."
			return 1
			;;
	esac

	debug-print "${FUNCNAME}: peg_rev = ${peg_rev}"

	return 0

}


## -- subversion__to_upper_case() ----------------------------------------- #
#
# @param $@ - the strings to upper case.
#
function subversion__to_upper_case() {
	echo "${@}" | tr "[a-z]" "[A-Z]"
}
